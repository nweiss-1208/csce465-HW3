#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_BUFFER_SIZE 256

int parse_log_file(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("Error opening file");
        return -1;
    }

    char temp_line[1024];
    char log_buffer[MAX_BUFFER_SIZE];

    if (fgets(temp_line, sizeof(temp_line), file) != NULL) {
        size_t len = strlen(temp_line);

        // Strip trailing newline if present
        if (len > 0 && temp_line[len - 1] == '\n') {
            temp_line[len - 1] = '\0';
            len--;
        }

        // Allow up to 255 printable characters so log_buffer can hold 255 chars + '\0'
        if (len > MAX_BUFFER_SIZE - 1) {
            fprintf(stderr, "Error: Input size (%zu bytes) exceeds buffer capacity (%d bytes). Rejecting input.\n", 
                    len, MAX_BUFFER_SIZE - 1);
            fclose(file);
            return -2;
        }

        // Safe copy after validation
        strncpy(log_buffer, temp_line, MAX_BUFFER_SIZE - 1);
        log_buffer[MAX_BUFFER_SIZE - 1] = '\0';

        printf("Successfully parsed log entry: %s\n", log_buffer);
    } else {
        fprintf(stderr, "Error: File is empty or reading failed.\n");
        fclose(file);
        return -1;
    }

    fclose(file);
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <log_file>\n", argv[0]);
        return 1;
    }

    return (parse_log_file(argv[1]) == 0) ? 0 : 1;
}
