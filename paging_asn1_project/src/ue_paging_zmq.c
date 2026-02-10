#include <stdio.h>
#include <zmq.h>

#include "Paging.h"
#include "per_decoder.h"
#include "xer_encoder.h"

int main() {
    void *ctx = zmq_ctx_new();
    void *sock = zmq_socket(ctx, ZMQ_PULL);
    zmq_connect(sock, "tcp://localhost:5555");

    uint8_t buffer[1024];

    printf("[DECODER] Waiting for Paging message...\n");
    int size = zmq_recv(sock, buffer, sizeof(buffer), 0);

    printf("[DECODER] Received %d bytes\n", size);

    Paging_t *paging = NULL;

    asn_dec_rval_t dr = uper_decode(
        NULL,
        &asn_DEF_Paging,
        (void **)&paging,
        buffer,
        size,
        0,
        0
    );

    if (dr.code != RC_OK) {
        printf("[DECODER] Decode failed\n");
        return -1;
    }

    printf("\n===== XER OUTPUT (Decoder) =====\n");
    xer_fprint(stdout, &asn_DEF_Paging, paging);

    zmq_close(sock);
    zmq_ctx_destroy(ctx);
    return 0;
}
