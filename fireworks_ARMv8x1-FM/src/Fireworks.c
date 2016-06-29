/* Copyright (c) ARM Ltd 2006-2016, All Rights Reserved.
 * Original code by Stephen Luce
 */


#define FRAME_BUFFER 0x80600000
#define LCD_WIDTH 800
#define LCD_HEIGHT 600

#define PLOT3 1 // draw 3x3 sparks
#define FOREVER 1 // don't terminate
#define HAVE_BANNER 1

#include <stdio.h>
#include <stdlib.h>


#include "SineTable.h"
#define sine(t) (((int)sineTable[(t)&0xff])<<2)
#define cosine(t) sine((t) + 64)
#include "BurstTable.h"

#define BLACK 0x0000
#define SPLAT 0x0421

// Display colours in RGB 565 format
#define RED   (unsigned short)0xf800
#define GREEN (unsigned short)0x07e0
#define BLUE  (unsigned short)0x001f

#define WHITE (unsigned short)(RED | GREEN | BLUE)

#define YELLOW  (unsigned short)(RED | GREEN)
#define CYAN    (unsigned short)(GREEN | BLUE)
#define MAGENTA (unsigned short)(RED | BLUE)

// User Switch
#define USERSW ((volatile unsigned char *) 0x001C010004)


static unsigned short colors[] =
{
	WHITE,

	RED,
	GREEN,
	BLUE,

	YELLOW,
	CYAN,
	MAGENTA
};

typedef struct Spark Spark;

typedef void (*BurstFunc)(Spark * parent);

typedef struct TypeInfo
{
	unsigned int  drag;     // drag function is (speed -= speed >> drag) each frame. (bigger numbers = less drag)
	BurstFunc     burst;    // called when spark dies
	BurstFunc     trail;	// called for every frame spark lives
	unsigned int  fade;     // fade period is (1 << fade) frames
	int           twinkle;  // twinkles out instead of fading
} TypeInfo;

static void newBurst(Spark * p);
static void newTrail(Spark * p);

static void fountainStop(Spark * p);
static void spray(Spark * p);

static void twinkleBurst(Spark * p);
static void twinkleTrail(Spark * p);
static void initSparks(void);
static void drawSparks(void);

enum
{
	burstShell = 0,
	burstSpark,
	trailSpark,
	fountainShell,
	fountainSpark,
	twinkleShell,
	twinkleSpark,
};

TypeInfo typeInfo[] = 
{
	{6, newBurst,     newTrail, 0},	// 0 burstShell
	{5, NULL,         NULL,     4},	// 1 burstSpark
	{3, NULL,         NULL,     6}, // 2 trailSpark

	{0, fountainStop, spray,    0}, // 3 fountainShell
	{5, NULL,         NULL,     6},	// 4 fountainSpark

	{7, twinkleBurst, twinkleTrail, 0},	// 5 twinkleShell
	{4, NULL,         NULL,         7, 1},	// 6 twinkleSpark
};

static Spark * sparks = NULL;
static int sparkCount = 0;
static int maxSparks = 0;
static int shellCount = 0;
static int maxShells = 7;
static const int sparkCapacity = 5000;
static const int gravity = 1 << 11;

#define inBounds(s) ((s)->x >= 0 && (s)->x < (LCD_WIDTH << 16) && (s)->y >= 0 && (s)->y < (LCD_HEIGHT << 16))

struct Spark
{
	int x;
	int y;
	int xs;
	int ys;
	unsigned char age;
	unsigned char type;
	unsigned char color;
	char data1;
};

#if HAVE_BANNER
#include <string.h>
#include "banner_data.h"

int banner_x = -BANNER_WIDTH;

static void plot_pixels(int pixels_width, int pixels_height, const pixel_t *pixels, int x, int y) {
	/* not very general: does not handle cropping on the top edge */
	int excess_width = (x + pixels_width) - LCD_WIDTH;
	int excess_height = (y + pixels_height) - LCD_HEIGHT;
	int width = (0 < excess_width) ? pixels_width - excess_width : pixels_width;
	int height = (0 < excess_height) ? pixels_height - excess_height : pixels_height;
	int skipleft = 0;
	int row;

	if (x < 0) {
		skipleft = -x;
		width += x;
		x = 0;
	}
	if (width < 0) return;
	if (height < 0) return;

	for (row = 0; row < height; ++row) {
		memcpy(&((unsigned short *)FRAME_BUFFER)[(row + y) * LCD_WIDTH + x],
			   &pixels[row * pixels_width + skipleft],
			   width * sizeof(pixel_t));
	}
}

static void moveBanner() {
	plot_pixels(BANNER_WIDTH, BANNER_HEIGHT, banner_data, banner_x, 0);
	++banner_x;
	if (banner_x == LCD_WIDTH) banner_x = -BANNER_WIDTH;
}
#endif /* HAVE_BANNER */

/* returns a pseudo random value >= 0 and < limit */
static __inline int random(int limit)
{
	return (rand() & 0xffff) * limit >> 16;
}

#if PLOT3
static void plot3(int x, int y, int color)
{
	if (0 < x)
		((volatile unsigned short *)FRAME_BUFFER)[y * LCD_WIDTH + x - 1] = color;
	((volatile unsigned short *)FRAME_BUFFER)[y * LCD_WIDTH + x] = color;
	if (x+1 < LCD_WIDTH)
		((volatile unsigned short *)FRAME_BUFFER)[y * LCD_WIDTH + x + 1] = color;
}

static void plot(int x, int y, int color)
{
	if (0 < y)
		plot3(x, y - 1, color);
	plot3(x, y, color);
	if (y+1 < LCD_HEIGHT)
		plot3(x, y + 1, color);
}
#else /* !PLOT3 */
static void plot(int x, int y, int color)
{
	((volatile unsigned short *)FRAME_BUFFER)[y * LCD_WIDTH + x] = color;
}
#endif /* !PLOT3 */

static int moveSpark(Spark * s)
{
	TypeInfo * ti = &typeInfo[s->type];
	if(inBounds(s))
	{
		plot(s->x >> 16, s->y >> 16, BLACK);
	}
	s->age--;
	if(s->age == 0)
	{
		if(ti->burst)
		{
			ti->burst(s);
		}
		return 0;
	}
	s->x += s->xs;
	s->y += s->ys;

	s->ys += gravity;

	s->xs -= s->xs >> ti->drag;
	s->ys -= s->ys >> ti->drag;

	if(ti->trail)
	{
		ti->trail(s);	
	}

	if(inBounds(s))
	{
		short color = colors[s->color];
		short fade = s->age << 5 >> ti->fade;
		if(fade < 32)
		{
			if(ti->twinkle)
			{
				if(fade < random(32))
				{
					color = 0;
				}
			}
			else
			{
				color &= fade * SPLAT;
			}
		}
		plot(s->x >> 16, s->y >> 16, color);
	}
	return 1;
}

static Spark * newSpark()
{
	if(sparkCount >= sparkCapacity)
	{
		abort();
	}
	sparkCount++;
	if(sparkCount > maxSparks)
	{
		maxSparks = sparkCount;
	}
	return sparks + sparkCount - 1;
}

static void newTrail(Spark * p)
{
	int direction;
	Spark * s = newSpark();
	s->x = p->x;
	s->y = p->y;
	direction = p->age * p->data1 + random(20);
	s->xs = p->xs + sine(direction) * 2;
	s->ys = p->ys + cosine(direction) * 2;
	s->color = p->color;
	s->type = trailSpark;
	s->age = random(30) + 30;

}

static void twinkleTrail1(Spark * p)
{
	int direction, speed;
	Spark * s = newSpark();
	s->x = p->x;
	s->y = p->y;
	direction = random(256);
	speed = random(4) + 1;
	s->xs = p->xs + sine(direction) * speed / 4;
	s->ys = p->ys + cosine(direction) * speed / 4;
	s->color = p->color;
	s->type = twinkleSpark;
	s->age = 140;
}

static void twinkleTrail(Spark * p)
{
	twinkleTrail1(p);
	twinkleTrail1(p);
	twinkleTrail1(p);
	twinkleTrail1(p);
}

static void spray1(Spark * p)
{
	int direction, speed, offset;
	Spark * s = newSpark();
	direction = random(21) - 10;
	speed = random(40);
	s->xs = sine(direction) * speed / 4;
	s->ys = cosine(direction) * -speed / 4;
	offset = random(16);
	s->x = p->x + s->xs * offset / 16;
	s->y = p->y + s->ys * offset / 16;
	s->color = p->color;
	s->type = fountainSpark;
	s->age = random(100) + 100;

}

static void spray(Spark * p)
{
	if(p->age == 128)
	{
		p->color = random(7);	
	}

	spray1(p);
	spray1(p);
	spray1(p);
	spray1(p);
}

static void fountainStop(Spark * p)
{
	shellCount--;
}

static void newBurst(Spark * p)
{
	int doubleBurst = random(10) < 2; // doubleBurst = 0 or 1
	int color = random(7);
	int speed = 16;
	int i;

	shellCount--;

	for(i = 0; i < 256; i++)
	{
		Spark * s = newSpark();
		s->x = p->x;
		s->y = p->y;
		s->xs = p->xs + ((int)burstXTable[i]) * speed;
		s->ys = p->ys + ((int)burstYTable[i]) * speed;
		s->color = color;
		s->type = burstSpark;
		s->age = 40 + random(20);
		if(doubleBurst && i == 255)
		{
			int c2 = color;
			do
			{
				color = random(7);			
			} while(color == c2);
			speed = -19;
			doubleBurst = 0;
			i = 0;
		}
	}
}

static void twinkleBurst(Spark * p)
{
	shellCount--;
	{
		int i;

		for(i = 0; i < p->data1; i++)
		{
			Spark * s = newSpark();
			int r = random(256);
			shellCount++;
			s->x = p->x;
			s->y = p->y;
			s->xs = p->xs + (((int)burstXTable[r])<<4);			
			s->ys = p->ys + (((int)burstYTable[r])<<4);				
			s->color = p->color;
			s->type = p->type;
			s->data1 = 0;
			s->age = 30;
		}
	}
}

static void newShell()
{
	int direction, speed;
	int r = random(100);
	int shellType = r < 10 ? fountainShell : r < 20 ? twinkleShell : burstShell;
	Spark * s = newSpark();
	s->x = random(LCD_WIDTH) << 16;
	s->y = (LCD_HEIGHT - 1) << 16;
	s->type = shellType;
	shellCount++;

	switch(shellType)
	{
	case fountainShell:
		s->age = 255;
		s->xs = 0;
		s->ys = 0;
		s->color = random(7);
		break;
	case twinkleShell:
		s->data1 = 3;
		s->color = 0;

		direction = random(20) +10;
		if(s->x > LCD_WIDTH << 15)
		{
			direction = -direction;	
		}
		speed = 14 + random(6);
		s->xs = sine(direction) * speed / 2;
		s->ys = cosine(direction) * -speed / 2;
		s->age = 200 + random(50);
		break;
	case burstShell:
		s->data1 = random(11) - 5;
		s->color = 4;

		direction = random(31) - 15;
		speed = 14 + random(8);
		s->xs = sine(direction) * speed / 2;
		s->ys = cosine(direction) * -speed / 2;
		s->age = 90 + random(40);
		break;
	}
}

static void initSparks()
{
	// uncomment the next line to introduce randomness
	// srand(time(NULL));
	sparks = malloc(sizeof (Spark) * sparkCapacity);
	if (!sparks) abort ();
	sparkCount = 0;
}

static void drawSparks(void)
{
	unsigned int user_switch;

        int i = 0;
	if(shellCount < maxShells)
	{
		newShell();
	}


	while(i < sparkCount)
	{
		Spark * s = &sparks[i];
		if(moveSpark(s))
		{
			i++;
		}
		else
		{
			*s = sparks[--sparkCount];
		}
	}

#if HAVE_BANNER
	user_switch = *USERSW;
	if ((user_switch & 1) == 0) moveBanner();
#endif /* HAVE_BANNER */
}


void fireworks(void)
{
#if !FOREVER
	int i;
#endif /* !FOREVER */
	initSparks();

#if FOREVER
	while (1)
#else /* !FOREVER */
	for (i = 0; i < 100000; i++)
#endif /* !FOREVER */
	{
		drawSparks();
	}
}

void clear_screen(void)
{
	unsigned int i;

	for (i = 0; i <= (LCD_WIDTH*LCD_HEIGHT); i++)
	{
		((volatile unsigned short *)FRAME_BUFFER)[i] = BLACK;
	}
}

extern void init_screen(unsigned int fb, unsigned int w, unsigned int h);   // in screen.c

void setup_screen(void)
{
    //init the screen registers
    init_screen(FRAME_BUFFER, LCD_WIDTH, LCD_HEIGHT);
    clear_screen();
}
