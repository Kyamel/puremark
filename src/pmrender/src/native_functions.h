#ifndef NATIVE_FUNCTIONS_H
#define NATIVE_FUNCTIONS_H

#ifdef __cplusplus
extern "C" {
#endif

// Definição do macro EXPORT dependendo da plataforma
#if defined(_WIN32) || defined(_WIN64)
#define EXPORT __declspec(dllexport)
#else
#define EXPORT __attribute__((visibility("default")))
#endif

// Funções exportadas
EXPORT int addInt(int x, int y);
EXPORT double multiplyDouble(double x, double y);
EXPORT void change_state();

// Funções relacionadas à estrutura someStructure
EXPORT const char* getSomeStructure();
EXPORT void freeSomeStructure(const char* json_string);

// Estrutura someStructure
typedef struct someStructure {
    int x;
    int y;
} someStructure;

#ifdef __cplusplus
}
#endif

#endif // NATIVE_FUNCTIONS_H
