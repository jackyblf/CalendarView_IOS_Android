%module calendarCore

%{
 /* Includes the header in the wrapper code */
#include "calendarCore.h"
%}

/* Parse the header file to generate wrappers */
%include "calendarCore.h"
