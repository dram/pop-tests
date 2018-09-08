define pop_exception_final();
    sys_exception_final();
    false -> pop_exit_ok;
    sysexit();
enddefine;  
