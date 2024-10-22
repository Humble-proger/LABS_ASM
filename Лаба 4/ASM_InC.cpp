#include <iostream>
#include <windows.h>
using namespace std;
extern "C" float _stdcall FUNC_F(float x);

int main()
{
    setlocale(LC_ALL, "Russian");
    SetConsoleCP(1251);
    float x;
    cout << "Введите число x: " << endl;
    cin >> x;
    x = FUNC_F(x);
    cout << "Результат: " << x << endl;
    return 0;
}
