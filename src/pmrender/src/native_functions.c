#include <stdio.h>
#include <stdlib.h>

#include "../lib/cmark-gfm/src/cmark-gfm.h"
#include "parson.h"

#if defined(_WIN32) || defined(_WIN64)
#define EXPORT __declspec(dllexport)
#else
#define EXPORT __attribute__((visibility("default")))
#endif

EXPORT int addInt(int x, int y) {
    return x + y;
}

EXPORT double multiplyDouble(double x, double y) {
    return x * y;
}


typedef struct someStructure {
    int x;
    int y;
} someStructure;

someStructure s = {5, 2};

EXPORT void change_state() {
    s.x = 1;
}

// Função para obter a estrutura serializada como JSON
EXPORT const char* getSomeStructure() {
    // Criando o objeto JSON
    JSON_Value *root_value = json_value_init_object();
    JSON_Object *root_object = json_value_get_object(root_value);

    // Adicionando valores ao objeto
    json_object_set_number(root_object, "x", s.x);
    json_object_set_number(root_object, "y", s.y);

    // Serializando o objeto JSON para uma string
    const char *json_string = json_serialize_to_string(root_value);

    return json_string; // A string deve ser liberada pelo chamador
}

EXPORT void freeSomeStructure(const char* json_string) {
    // Liberando a string JSON
     // Escreve o log em um arquivo
    FILE *log_file = fopen("native-func-log.txt", "a");
    if (log_file != NULL) {
        fprintf(log_file, "freeSomeStructure called to: %s.\n", json_string);
        fclose(log_file);
    } else {
        // Se não conseguiu abrir o arquivo de log, tente salvar o erro
        fprintf(stderr, "Erro ao abrir o arquivo de log.\n");
    }

    free((void*)json_string);
}