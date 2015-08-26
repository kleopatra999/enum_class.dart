// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:enum_class_generator/enum_class_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

final String correctInput = r'''
library test_enum;

import 'package:built_collection/built_collection.dart';
import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
''';

final String correctOutput = r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

const TestEnum _$yes = const TestEnum._('yes');
const TestEnum _$no = const TestEnum._('no');
const TestEnum _$maybe = const TestEnum._('maybe');

TestEnum _$valueOf(String name) {
  switch (name) {
    case 'yes':
      return _$yes;
    case 'no':
      return _$no;
    case 'maybe':
      return _$maybe;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<TestEnum> _$values =
    new BuiltSet<TestEnum>(const [_$yes, _$no, _$maybe,]);
''';

void main() {
  group('generator', () {
    test('produces correct output for correct input', () async {
      expect(await generate(correctInput), endsWith(correctOutput));
    });

    // TODO(davidmorgan): it would be better to fail with an error message.
    test('fails silently on missing enum_class import', () async {
      expect(await generate(r'''
library test_enum;

import 'package:built_collection/built_collection.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
'''), isEmpty);
    });

    test('fails with error on missing part statement', () async {
      expect(await generate(r'''
library test_enum;

import 'package:built_collection/built_collection.dart';
import 'package:enum_class/enum_class.dart';

part 'src_par.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Import generated part: part 'test_enum.g.dart';
'''));
    });

    test('fails with error on non-const static fields', () async {
      expect(await generate(r'''
library test_enum;

import 'package:built_collection/built_collection.dart';
import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static TestEnum yes = _$yes;
  static TestEnum no = _$no;
  static TestEnum maybe = _$maybe;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Make field "yes" const. Make field "no" const. Make field "maybe" const.
'''));
    });

    test('fails with error on non-const non-static fields', () async {
      expect(await generate(r'''
library test_enum;

import 'package:built_collection/built_collection.dart';
import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  TestEnum yes = _$yes;
  TestEnum no = _$no;
  TestEnum maybe = _$maybe;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Make field "yes" static const. Make field "no" static const. Make field "maybe" static const.
'''));
    });

    test('ignores static const fields of wrong type', () async {
      expect(await generate(r'''
library test_enum;

import 'package:built_collection/built_collection.dart';
import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const int count = 0;
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
'''), endsWith(correctOutput));
    });

    test('fails with error on incorrect rhs in field declaration', () async {
      expect(await generate(r'''
library test_enum;

import 'package:built_collection/built_collection.dart';
import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$no;
  static const TestEnum no = _$maybe;
  static const TestEnum maybe = _$yes;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Initialize field "yes" with generated value "_$yes". Initialize field "no" with generated value "_$no". Initialize field "maybe" with generated value "_$maybe".
'''));
    });

    test('fails with error on missing constructor', () async {
      expect(await generate(r'''
library test_enum;

import 'package:built_collection/built_collection.dart';
import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Constructor: const TestEnum._(String name) : super(name);
'''));
    });

    test('fails with error on incorrect constructor', () async {
      expect(await generate(r'''
library test_enum;

import 'package:built_collection/built_collection.dart';
import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Constructor: const TestEnum._(String name) : super(name);
'''));
    });

    test('fails with error on too many constructors', () async {
      expect(await generate(r'''
library test_enum;

import 'package:built_collection/built_collection.dart';
import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  const TestEnum._(String name) : super(name);
  TestEnum._create(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
  static TestEnum valueOf(String name) => _$valueOf(name);
}

abstract class BuiltSet<T> {
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Constructor: const TestEnum._(String name) : super(name);
'''));
    });

    test('fails with error on missing values getter', () async {
      expect(await generate(r'''
library test_enum;

import 'package:built_collection/built_collection.dart';
import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  const TestEnum._(String name) : super(name);

  static TestEnum valueOf(String name) => _$valueOf(name);
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Getter: static BuiltSet<TestEnum> get values => _$values;
'''));
    });

    test('fails with error on missing valueOf', () async {
      expect(await generate(r'''
library test_enum;

import 'package:built_collection/built_collection.dart';
import 'package:enum_class/enum_class.dart';

part 'test_enum.g.dart';

class TestEnum extends EnumClass {
  static const TestEnum yes = _$yes;
  static const TestEnum no = _$no;
  static const TestEnum maybe = _$maybe;

  const TestEnum._(String name) : super(name);

  static BuiltSet<TestEnum> get values => _$values;
}
'''), endsWith(r'''
part of test_enum;

// **************************************************************************
// Generator: EnumClassGenerator
// Target: class TestEnum
// **************************************************************************

// Error: Please make changes to use EnumClass.
// TODO: Method: static TestEnum valueOf(String name) => _$valueOf(name);
'''));
    });
  });
}

// Test setup.

Future<String> generate(String source) async {
  final tempDir =
      Directory.systemTemp.createTempSync('enum_class_generator.dart.');
  final packageDir = new Directory(tempDir.path + '/packages')..createSync();
  final enumClassDir = new Directory(packageDir.path + '/enum_class')
    ..createSync();
  final enumClassFile = new File(enumClassDir.path + '/enum_class.dart')
    ..createSync();
  enumClassFile.writeAsStringSync(enumClassSource);

  final libDir = new Directory(tempDir.path + '/lib')..createSync();
  final sourceFile = new File(libDir.path + '/test_enum.dart');
  sourceFile.writeAsStringSync(source);

  await build([], [new EnumClassGenerator()],
      projectPath: tempDir.path, librarySearchPaths: <String>['lib']);
  final outputFile = new File(libDir.path + '/test_enum.g.dart');
  return outputFile.existsSync() ? outputFile.readAsStringSync() : '';
}

const String enumClassSource = r'''
library enum_class;

class EnumClass {
  final String name;

  const EnumClass(this.name);

  @override
  String toString() => name;
}
''';

const String builtCollectionSource = r'''
library built_collection;

abstract class BuiltSet<E> {
}
''';