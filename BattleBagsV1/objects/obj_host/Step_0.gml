/// @description
buffer_seek(client_buffer, buffer_seek_start, 0);
buffer_write(client_buffer, buffer_string, "g");
network_send_udp_raw(client_socket, server_ip, server_port, client_buffer, buffer_tell(client_buffer));