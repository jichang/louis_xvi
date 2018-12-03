import 'dart:math';

abstract class Generator {
  String generate(Random random);
}

class AlphabetGenerator extends Generator {
  String source = 'abcdefghigklmnopqrstuvwxyz';

  String generate(Random random) {
    int randomInt = random.nextInt(source.length);

    return source[randomInt];
  }
}

class NumberGenerator extends Generator {
  String source = '0123456789';

  String generate(Random random) {
    int randomInt = random.nextInt(source.length);

    return source[randomInt];
  }
}

class SymbolGenerator extends Generator {
  String source = '`+-*%`~[]{}|/\\<>,.';

  String generate(Random random) {
    int randomInt = random.nextInt(source.length);

    return source[randomInt];
  }
}

class SequenceGenerator extends Generator {
  Generator sourceGenerator;
  int length;

  SequenceGenerator(this.sourceGenerator, this.length);

  String generate(Random random) {
    String result = "";
    for (var i = 0; i < this.length; i++) {
      result += this.sourceGenerator.generate(random);
    }

    return result;
  }
}

class ChoiceGenerator extends Generator {
  List<Generator> generators;

  ChoiceGenerator(this.generators);

  String generate(Random random) {
    if (this.generators.length == 0) {
      return "";
    }

    if (this.generators.length == 1) {
      return this.generators[0].generate(random);
    }

    int index = random.nextInt(generators.length);

    return generators[index].generate(random);
  }
}
