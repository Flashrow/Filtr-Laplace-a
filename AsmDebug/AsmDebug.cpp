// AsmDebug.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
#include <wtypes.h>


// program do debugowania programu ASM

typedef unsigned char byte;
typedef int (*CONVERT_TO_RPN)(byte[], int, int, byte[]);
int main()
{
    
    //byte a[27] = { 255,255,255,255,255,255,255,255,255,255,255,255,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255 };
    byte a[75] = { 255, 255, 255, 255, 255, 255, 0, 0, 0, 255, 255, 255, 255, 255, 255, 
                   255, 255, 255, 255, 255, 255, 0, 0, 0, 255, 255, 255, 255, 255, 255,
                   255, 255, 255, 255, 255, 255, 0, 0, 0, 255, 255, 255, 255, 255, 255,
                   255, 255, 255, 255, 255, 255, 0, 0, 0, 255, 255, 255, 255, 255, 255,
                   255, 255, 255, 255, 255, 255, 0, 0, 0, 255, 255, 255, 255, 255, 255 };
    byte b[75];
    std::cout << "a address:" << &a;
    std::cout << "b address:" << &b;
    CONVERT_TO_RPN convertToRpnProc;
    HINSTANCE hDll = NULL;
    hDll = LoadLibrary(TEXT("AsmDLL"));
    convertToRpnProc = (CONVERT_TO_RPN)GetProcAddress(hDll, "laplaceFilter");
    (convertToRpnProc)(a, 5, 5, b);
    for (int i = 0; i < 27; i++) {
        std::cout << "b[" << i << "] = " << b[i]*1 << std::endl;
    }

    std::cout << "Hello World!\n";
}

// Run program: Ctrl + F5 or Debug > Start Without Debugging menu
// Debug program: F5 or Debug > Start Debugging menu

// Tips for Getting Started: 
//   1. Use the Solution Explorer window to add/manage files
//   2. Use the Team Explorer window to connect to source control
//   3. Use the Output window to see build output and other messages
//   4. Use the Error List window to view errors
//   5. Go to Project > Add New Item to create new code files, or Project > Add Existing Item to add existing code files to the project
//   6. In the future, to open this project again, go to File > Open > Project and select the .sln file
