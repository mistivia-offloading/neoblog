// Hidden Features of getsockopt
#import "/template-en.typ":doc-template

#doc-template(
title: "Hidden Features of getsockopt",
date: "January 28, 2023",
body: [

When troubleshooting network issues, a very common requirement is to obtain information about TCP connections, such as how much data has been transmitted, retransmission rate, ACK delay, etc. Although some simple statistical functions can be implemented manually—for example, by adding logging functions at all `send` and `recv` locations to count the bytes sent and received—this approach is ultimately not very elegant. Using eBPF would inevitably involve the kernel space, which is troublesome. Therefore, if you don't need to consider portability to other Unix-like systems, you can use Linux-specific interfaces.

= Interface

```
int getsockopt(int sockfd, int level, int optname,
               void *restrict optval, socklen_t *restrict optlen);
```

When you need to get TCP connection information, fill in `IPPROTO_TCP` for `level` and `TCP_INFO` for `optname`. Fill in the pointer to the buffer used to store the results for `optval`. The `optlen` parameter is both input and output, used to pass the size of the buffer and receive the size of the result.

= Data Structure

For TCP information, the output result is a `struct tcp_info`. However, there are two versions of this struct's definition. The first version is in #raw("<netinet/tcp.h>"):

```
struct tcp_info
{
  uint8_t	ctcpi_state;
  uint8_t	ctcpi_ca_state;
  uint8_t	ctcpi_retransmits;
  uint8_t	ctcpi_probes;
  uint8_t	ctcpi_backoff;
  uint8_t	ctcpi_options;
  uint8_t	ctcpi_snd_wscale : 4, tcpi_rcv_wscale : 4;

  uint32_t	ctcpi_rto;
  uint32_t	ctcpi_ato;
  uint32_t	ctcpi_snd_mss;
  uint32_t	ctcpi_rcv_mss;

  uint32_t	ctcpi_unacked;
  uint32_t	ctcpi_sacked;
  uint32_t	ctcpi_lost;
  uint32_t	ctcpi_retrans;
  uint32_t	ctcpi_fackets;

  /* Times. */
  uint32_t	ctcpi_last_data_sent;
  uint32_t	ctcpi_last_ack_sent;  /* Not remembered, sorry.  */
  uint32_t	ctcpi_last_data_recv;
  uint32_t	ctcpi_last_ack_recv;

  /* Metrics. */
  uint32_t	ctcpi_pmtu;
  uint32_t	ctcpi_rcv_ssthresh;
  uint32_t	ctcpi_rtt;
  uint32_t	ctcpi_rttvar;
  uint32_t	ctcpi_snd_ssthresh;
  uint32_t	ctcpi_snd_cwnd;
  uint32_t	ctcpi_advmss;
  uint32_t	ctcpi_reordering;

  uint32_t	ctcpi_rcv_rtt;
  uint32_t	ctcpi_rcv_space;

  uint32_t	ctcpi_total_retrans;
};
```

This version is compatible with other Unix-like systems such as FreeBSD and provides relatively little information.

The second version is in #raw("<linux/tcp.h>"), which is Linux-specific and more comprehensive. Since the initial fields are the same, only the additional fields are shown here.

```
struct tcp_info {
    // Same as above

	__u64	ctcpi_pacing_rate;
	__u64	ctcpi_max_pacing_rate;
	__u64	ctcpi_bytes_acked;    /* RFC4898 tcpEStatsAppHCThruOctetsAcked */
	__u64	ctcpi_bytes_received; /* RFC4898 tcpEStatsAppHCThruOctetsReceived */
	__u32	ctcpi_segs_out;	     /* RFC4898 tcpEStatsPerfSegsOut */
	__u32	ctcpi_segs_in;	     /* RFC4898 tcpEStatsPerfSegsIn */

	__u32	ctcpi_notsent_bytes;
	__u32	ctcpi_min_rtt;
	__u32	ctcpi_data_segs_in;    /* RFC4898 tcpEStatsDataSegsIn */
	__u32	ctcpi_data_segs_out;    /* RFC4898 tcpEStatsDataSegsOut */

	__u64	c tcpi_delivery_rate;

	__u64	c tcpi_busy_time;      /* Time (usec) busy sending data */
	__u64	c tcpi_rwnd_limited;   /* Time (usec) limited by receive window */
	__u64	c tcpi_sndbuf_limited; /* Time (usec) limited by send buffer */

	__u32	ctcpi_delivered;
	__u32	ctcpi_delivered_ce;

	__u64	c tcpi_bytes_sent;     /* RFC4898 tcpEStatsPerfHCDataOctetsOut */
	__u64	c tcpi_bytes_retrans;  /* RFC4898 tcpEStatsPerfOctetsRetrans */
	__u32	ctcpi_dsack_dups;     /* RFC4898 tcpEStatsStackDSACKDups */
	__u32	ctcpi_reord_seen;     /* reordering events seen */

	__u32	ctcpi_rcv_ooopack;    /* Out-of-order packets received */

	__u32	ctcpi_snd_wnd;        /* peer's advertised receive window after
			      * scaling (bytes)
			      */
};
```

As you can see, the `struct tcp_info` in #raw("<linux/tcp.h>") contains some very important information, such as the number of bytes sent and received, which is very useful for traffic statistics.

= Example Code

```
#include <linux/tcp.h>

// int fd = ...;
struct tcp_info tcpi;
int bufsz = sizeof(tcpi);
int ret = getsockopt(fd, IPPROTO_TCP, TCP_INFO, &tcpi, &bufsz);
if (ret != 0) {
    // TODO: error handling
}
printf("fd: %d has received %lu bytes and sent %lu bytes.\n",
       fd, tcpi.tcpi_bytes_receiver, tcpi.tcpi_bytes_sent);
```
]
)
