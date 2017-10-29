User Guide
===============
Ensure rpdb in your sys.path

1. import rpdb
2. client code 
    use tcp::
        # default addr is 127.0.0.1 
        # default port is 4444
        rpdb.set_trace(addr, port)

        then, listen at (addr, port)

    use unix socket::
        rpdb.set_trace(path='/var/log/my.sock')

        then, listen at /var/log/my.sock
3. do debug in rpdb at listening socket
 
   
Trap List
============
1. when use unix socket, process you run rpdb, must have read/write permission on that socket file
