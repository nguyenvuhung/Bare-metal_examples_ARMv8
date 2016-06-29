/* calendar.c simple program to output a calendar month */

/* Copyright (C) ARM Limited, 2009-2011. All rights reserved. */

/* This code contains a deliberate bug for you to locate using DS-5 Debugger */


#include <stdio.h>

// DS-5 Debugger enables semihosting automatically if either symbols
//  "__auto_semihosting" or "__semihosting_library_function" are present in an image.
// ARM Compiler 6 adds "__semihosting_library_function" automatically to an image
//  at link time if that image uses any semihosting-using functions.
// If compiling with gcc or an earlier release of armcc, use the alias symbol definition:
//void __auto_semihosting(void) __attribute__ ((alias("main")));


struct Date_Format
{
    int day;
    int month;
    int year;
};

void nextday(void);                                /* Function prototype */
void calcDaysInMonth(void);                        /* Function prototype */
struct Date_Format date;                           /* Variable declaration */
int daysInMonth;                                   /* Variable declaration */

int main(void)
{
    int dflag, mflag;

    printf("\n\nThis program will read the date in the form yyyy mm dd\n");
    printf("then display the dates for the following calendar month.");
    printf("\n\nPlease type the date (yyyy mm dd) -> ");
    scanf ("%d%d%d", &date.year, &date.month, &date.day);

    // Check input values
    if ((date.month > 12) || (date.day > 31))
    {
        printf("\nIncorrect date values\n ");
        return 0;
    }

    printf("\n\nThe month following ");
    printf("%4d %2d %2d is:\n\n", date.year, date.month, date.day);
    dflag = date.day;
    mflag = date.month;
    calcDaysInMonth();

    while (date.day != dflag && date.month - mflag < 2)
    {
        printf("%4d %2d %2d\n", date.year, date.month, date.day);
        nextday();
    }
    printf("\n\n");

    return 0;
}

void nextday(void)                                 /* Function definition */
{
    if (date.day >= daysInMonth)
    {
        date.day = 1;
        if (date.month == 12)
        {
            date.month = 1;
            date.year++;
        }
        else
            date.month++;
    }
    else
    date.day++;
}

void calcDaysInMonth(void)                         /* Function definition */
{
    switch (date.month)
    {
        case 2:
            if (date.year % 400 == 0)
                daysInMonth = 29;
            else
            if (date.year % 100 == 0)
                daysInMonth = 28;
            else
            if (date.year % 4 == 0)
                daysInMonth = 29;
            else
                daysInMonth = 28;
            break;

        case 4: case 6: case 9:
            daysInMonth = 30;
            break;

        default:
            daysInMonth = 31;
            break;
    }
    nextday();
}
