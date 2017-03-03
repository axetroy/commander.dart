/**
 * Created by axetroy on 2017/3/2.
 */
class EventEmitter {

  Map<String, List<Function>> events = new Map();

  EventEmitter() {
  }

  Function on(String event, Function handler) {
    final List eventContainer = this.events.putIfAbsent(event, () => new List<Function>());
    eventContainer.add(handler);
    final Function off = this.off;
    final Function offThisListener = () {
      off(event);
    };
    return offThisListener;
  }

  void once(String event, Function handler) {
    final List eventContainer = this.events.putIfAbsent(event, () => new List<Function>());
    eventContainer.add(() {
      handler();
      this.off(event);
    });
  }

  off(String event) {
    events.remove(event);
  }

  void emit(String event, [dynamic data]) {
    final List eventContainer = events[event] ?? [];
    eventContainer.forEach((Function handler) {
      if (handler is Function) handler();
    });
  }

  void clear() {
    events.clear();
  }
}