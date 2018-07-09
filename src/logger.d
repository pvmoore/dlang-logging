module logger;

import std.datetime	: Clock;
import std.stdio	: File;
import std.format	: format;


final class FileLogger {
    this(string filename) {
        this.filename = filename;
        this.file     = File(filename, "w");
    }
    ~this() {
        file.close();
    }
    void flush() nothrow {
        try{
            if(!file.isOpen) return;
            file.flush();
        }catch(Exception e) {}
    }
    void close() {
        if(file.isOpen) file.close();
    }
    void log(string str) nothrow {
        doLog(str);
    }
    void log(A...)(string fmt, A args) nothrow {
        try{
    	    doLog(format(fmt, args));
    	}catch(Exception e) {}
    }
private:
    string filename;
    File file;

    void doLog(string str) nothrow {
    	try{
    		if(!file.isOpen) {
                file.open(filename, "w");
            }
            auto dt = Clock.currTime();
    		string dateTime = "[%02u:%02u:%02u.%03u] "
    		    .format(dt.hour, dt.minute, dt.second, dt.fracSecs.total!("msecs"));

    		file.write(dateTime);
    		file.write(str);
    		file.write("\n");
    	}catch(Exception e) {}
    }
}

