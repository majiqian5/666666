#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <os/lock.h>

@interface PKDServer : NSObject
- (instancetype)initForService:(id)service database:(id)database proxyFactory:(id)proxyFactory;
- (instancetype)initWithConnection:(id)connection queue:(id)queue database:(id)database proxyFactory:(id)proxyFactory;
@end

static os_unfair_lock gServerLock = OS_UNFAIR_LOCK_INIT;
static id gServer;

static void RememberServer(id server) {
    os_unfair_lock_lock(&gServerLock);
    gServer = server;
    os_unfair_lock_unlock(&gServerLock);
}

static id ActiveServer(id self, SEL selector) {
    (void)self;
    (void)selector;

    os_unfair_lock_lock(&gServerLock);
    id server = gServer;
    os_unfair_lock_unlock(&gServerLock);
    return server;
}

%group ConnectionInitializer

%hook PKDServer

- (instancetype)initWithConnection:(id)connection queue:(id)queue database:(id)database proxyFactory:(id)proxyFactory {
    PKDServer *server = %orig;
    RememberServer(server);
    return server;
}

%end

%end

%group ServiceInitializer

%hook PKDServer

- (instancetype)initForService:(id)service database:(id)database proxyFactory:(id)proxyFactory {
    PKDServer *server = %orig;
    RememberServer(server);
    return server;
}

%end

%end

%ctor {
    Class serverClass = objc_getClass("PKDServer");
    SEL connectionInitializer = @selector(initWithConnection:queue:database:proxyFactory:);
    SEL serviceInitializer = @selector(initForService:database:proxyFactory:);
    BOOL hasConnectionInitializer = serverClass && class_getInstanceMethod(serverClass, connectionInitializer);
    BOOL hasServiceInitializer = serverClass && class_getInstanceMethod(serverClass, serviceInitializer);
    SEL serverSelector = sel_registerName("server");

    if (!serverClass || class_getClassMethod(serverClass, serverSelector) ||
        (!hasConnectionInitializer && !hasServiceInitializer)) {
        return;
    }

    if (!class_addMethod(object_getClass(serverClass), serverSelector, (IMP)ActiveServer, "@@:")) {
        return;
    }

    if (hasConnectionInitializer) {
        %init(ConnectionInitializer);
    }
    if (hasServiceInitializer) {
        %init(ServiceInitializer);
    }
}
