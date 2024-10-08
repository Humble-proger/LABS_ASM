#include <iostream>
#include <string>
#include <windows.h>

extern "C" void SUBSTRING(char * buf, char * new_string, int start, int len_string);

using namespace std;
int main()
{
    setlocale(LC_ALL, "Russian");
    SetConsoleCP(1251);
    string old_string;
    cout << "Введите строчку: " << endl;
    getline(cin, old_string);
    char* edit_string = new char[old_string.size()+1];
    snprintf(edit_string, old_string.size()+1, "%s", old_string.c_str());
    cout << "Введите номер позиции: " << endl;
    int start_point = 0;
    int len_str = 0;
    cin >> start_point;
    cout << "Введите длину подстроки: " << endl;
    cin >> len_str;
    if (start_point + len_str > old_string.size()+1 || start_point < 0 || len_str < 0) {
        cerr << "ERROR: Данные, введены некорректно." << endl;
        return 1;
    }
    char* new_string = new char[start_point + len_str + 1];
    SUBSTRING(edit_string, new_string, start_point, len_str);
    cout << "Результат: " << new_string << endl;
    delete[] edit_string, new_string;
    return 0;
}
