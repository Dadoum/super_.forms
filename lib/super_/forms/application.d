module super_.forms.application;

import core.runtime: Runtime;
import ddbus;
import std.algorithm;
import std.array;
import std.concurrency;
import std.datetime;
import std.meta;
import std.stdio;
import std.string;
import std.traits;
import super_.forms.drawing;
import super_.forms.renderer.renderer;
import super_.forms.themeengine;
import super_.forms.utils;
import super_.forms.windowing.defs;
import tinyevent;

enum ApplicationFlags {
    none = 0,
    unique = 1 << 0
}

/++
 + An application is what manages window and coordinate rendering and events.
 +/
@safe private shared class ApplicationPriv {
    private const(ApplicationFlags) flags;
    private __gshared Connection conn;
    private shared(bool[]) idRunning = [];
    private shared(bool) interrupted;
    private shared(bool) launched = false;
    private shared(int) exitCode = 0;
    private shared(bool) requiresDbusCheck = false;

    private Event!(string[]) startedEvent;
    private Event!(string[]) activatedEvent;

    package(super_.forms) immutable(string) identifier;
    package(super_.forms) shared(Backend) backend;
    package(super_.forms) shared(Renderer) renderer;
    package(super_.forms) shared(ThemeEngine) themeEngine;

    static shared(Application) instance;

    @property ref shared(Event!(string[])) started() { return startedEvent; }
    @property ref shared(Event!(string[])) activated() { return activatedEvent; }

    this(string identifier, ApplicationFlags flags = ApplicationFlags.none) shared @trusted {
        if (instance !is null) {
            throw new DuplicateAppException();
        } else {
            instance = this;
        }
        this.identifier = identifier;
        this.flags = flags;

        this.backend = BackendBuilder.buildBestBackend();

        this.themeEngine = new SuperFormsThemeEngine();// ThemeEngine.buildThemeEngine(backend);

        foreach(builderFunc; backend.rendererBuilders()) {
            this.renderer = builderFunc(backend);
            if (renderer) {
                goto success;
            }
        }

        throw new RendererException("No renderer is available on this device. ");

      success:
        debug {
            import std.stdio;
            writefln!"Application %s initialized with %s backend, %s renderer and %s theme engine. "(
                identifier,
                typeOf!backend,
                typeOf!renderer,
                typeOf!themeEngine,
            );
        }
    }

    ~this() @trusted {
        instance = null;
    }

    package(super_.forms) ulong registerLoop(shared(void delegate() shared) del) @trusted {
        import core.atomic;
        shared(ulong) id = idRunning.length;
        idRunning ~= true;
        spawn(() shared {
            while (!launched) { }
            while (idRunning[id]) {
                del();
            }
        });
        return id;
    }

    package(super_.forms) void unregisterLoop(ulong id) {
        idRunning[id] = false;
    }

    int run() @trusted {
        import core.thread.osthread;
        import std.concurrency;

        conn = connectToBus();
        string[] args = Runtime.args;

        if (flags & ApplicationFlags.unique) {
            requiresDbusCheck = true;
            BusName bus = busName(identifier);
            InterfaceName iface = interfaceName(identifier);
            ObjectPath path = ObjectPath("/");
            if (!conn.requestName(bus)) {
                PathIface obj = new PathIface(conn, bus, path, iface);
                obj.activate(args);
                Application.exit(0);
            } else {
                MessageRouter router = new MessageRouter();
                MessagePattern patt = MessagePattern(path, iface, "activate");
                router.setHandler(patt, (string[] args) => activated.emit(args[1..$]));
                conn.registerRouter(router);
                destroy(patt);
            }
            destroy(bus);
            destroy(iface);
            destroy(path);
        }

        started.emit(args);
        destroy(args);

        if (flags & ApplicationFlags.unique) {
            spawn(() shared {
                while (!interrupted) {
                    conn.tick();
                    Thread.sleep(dur!"msecs"(200));
                }
            });
        }

        launched = true;
        while (!interrupted) {
            backend.waitForEvents;
        }

        foreach (ref idR; idRunning) {
            idR = false;
        }

        return exitCode;
    }

    void exit(int exitCode = 0) {
        import std.stdio;
        this.exitCode = exitCode;
        interrupted = true;
    }
}

alias Application = shared(ApplicationPriv);
