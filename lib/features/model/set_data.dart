class SetData {
  String prev;
  String kg;
  String reps;
  bool done;

  SetData({
    required this.prev,
    required this.kg,
    required this.reps,
    this.done = false,
  });

  SetData copy() {
    return SetData(prev: prev, kg: kg, reps: reps, done: done);
  }
}
