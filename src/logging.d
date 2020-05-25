module logging;

import std.datetime	: Clock;
import std.stdio	: writefln, File;
import std.conv		: to;
import std.format	: format;
import std.file     : exists, mkdir;

public:

import logger;

private:

__gshared File file;
__gshared globalLevel = Level.INFO;
__gshared bool eagerFlushing = false;

public:

enum Level : int {
	FINE=0,
	INFO,
	WARNING,
	ERROR
}

shared static ~this() {
    file.close();
}

void setEagerFlushing(bool flag) {
	eagerFlushing = flag;
}
void setLogLevel(Level level) { globalLevel = level; }


void log(T, A...)(T src, string fmt, A args) if(is(T==class) || is(T==interface)) {
	doLog("[%s] ".format(T.stringof) ~ format(fmt, args), Level.INFO);
}

void logfine(A...)(string fmt, A args) nothrow {
	doLog(fmt, Level.FINE, args);
}
void logfine(string str) nothrow {
	doLog(str, Level.FINE);
}
void log(A...)(string fmt, A args) nothrow {
	doLog(fmt, Level.INFO, args);
}
void log(string str) nothrow {
	doLog(str, Level.INFO);
}
void logf(A...)(string fmt, A args) nothrow {
	doLog(fmt, Level.INFO, args);
    flushLog();
}
void logf(string str) nothrow {
	doLog(str, Level.INFO);
    flushLog();
}
void loginfo(A...)(string fmt, A args) nothrow {
	doLog(fmt, Level.INFO, args);
}
void loginfo(string str) nothrow {
	doLog(str, Level.INFO);
}
void logwarn(A...)(string fmt, A args) nothrow {
	doLog(fmt, Level.WARNING, args);
}
void logwarn(string s) nothrow {
	doLog(s, Level.WARNING);
}
void logerror(A...)(string fmt, A args) nothrow {
	doLog(fmt, Level.ERROR, args);
}
void logerror(string str) nothrow {
	doLog(str, Level.ERROR);
}
void flushLog() nothrow {
	try{
		if(!file.isOpen) return;
		file.flush();
	}catch(Exception e) {
		dang(e.msg);
	}
}

// ---------------------------------------------------------------------------
private:

void openLogFile() {
    if(!exists(".logs/")) mkdir(".logs");
    if(!file.isOpen) file.open(".logs/log.log", "w");
}
void dang(string s) nothrow {
    try{
        writefln("Logging error: %s", s);
        import core.stdc.stdio : fflush, stderr, stdout;
        fflush(stderr);
        fflush(stdout);
    }catch(Exception e) {}
}

void doLog(A...)(string fmt, Level level, A args) nothrow {
    if(level<globalLevel) return;
    try{
        doLog(format(fmt, args), level);
    }catch(Exception e) {
       dang(e.msg);
    }
}

void doLog(string str, Level level) nothrow {
	if(level<globalLevel) return;
	try{
		openLogFile();

        auto dt = Clock.currTime();
		string dateTime = "[%02u:%02u:%02u.%03u] "
		    .format(dt.hour, dt.minute, dt.second, dt.fracSecs.total!("msecs"));
		file.write(dateTime);

		if(level==Level.WARNING) file.write("WARNING! ");
		else if(level==Level.ERROR) file.write("ERROR! ");

		file.write(str);
		file.write("\n");
		//file.flush();	// uncomment this for debugging purposes

		if(eagerFlushing) file.flush();

	}catch(Exception e) {
		dang(e.msg);
	}
}


