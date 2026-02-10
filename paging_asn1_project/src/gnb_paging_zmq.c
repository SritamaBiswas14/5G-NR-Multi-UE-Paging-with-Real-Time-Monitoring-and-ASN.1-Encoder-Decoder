#include <stdio.h>
#include <string.h>
#include <zmq.h>

#include "Paging.h"
#include "per_encoder.h"

int main() {
    void *ctx = zmq_ctx_new();
    void *sock = zmq_socket(ctx, ZMQ_PUSH);
    zmq_bind(sock, "tcp://*:5555");

    Paging_t paging;
    memset(&paging, 0, sizeof(paging));

    /* Create one PagingRecord */
    PagingRecord_t *rec = calloc(1, sizeof(*rec));

    rec->ue_Identity.present = UE_Identity_PR_imsi;
    OCTET_STRING_fromString(
        &rec->ue_Identity.choice.imsi,
        "001010123456789"
    );

    /* Add record to SEQUENCE OF */
    ASN_SEQUENCE_ADD(&paging.pagingRecordList.list, rec);

    uint8_t buffer[1024];
    asn_enc_rval_t er = uper_encode_to_buffer(
        &asn_DEF_Paging,
        NULL,
        &paging,
        buffer,
        sizeof(buffer)
    );

    if (er.encoded <= 0) {
        printf("[ENCODER] Encoding failed\n");
        return -1;
    }

    int bytes = (er.encoded + 7) / 8;
    zmq_send(sock, buffer, bytes, 0);

    printf("[ENCODER] Sending %d bytes\n", bytes);

    zmq_close(sock);
    zmq_ctx_destroy(ctx);
    return 0;
}
