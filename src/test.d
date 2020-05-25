module test;

import std.stdio : writefln;
import std.range : iota;
import std.parallelism : parallel;

import logging;

void main(string[] args) {
    setLogLevel(Level.FINE);
	log("Testing logging");

	log("hello there %s", 10);

	logfine("hello %s %s", "pete", 3.3);

    foreach(i; parallel(iota(0,100))) {
        log("hello there %s", i);
    }

    auto logger = new FileLogger(".logs/log2.txt");
    logger.log("hello");
    logger.log("My number is %s", 17);


    class MyClass {

    }
    auto mc = new MyClass;

    mc.log("I am some logging %s", 77);

}

