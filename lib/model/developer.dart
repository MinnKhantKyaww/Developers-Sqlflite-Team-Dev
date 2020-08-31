class Developer {
  final int id;
  final String name;
  final int age;
  final String heading;

  Developer({this.id, this.name, this.age, this.heading});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "age": age,
      "heading": heading
    };
  }
}
