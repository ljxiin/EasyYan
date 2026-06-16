import 'package:easy_yan/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders dashboard shell and home widgets', (tester) async {
    await tester.pumpWidget(const EasyYanApp());

    expect(find.text('考研数学刷题系统'), findsOneWidget);
    expect(find.text('首页 / 学习概览'), findsOneWidget);
    expect(find.text('今日任务'), findsOneWidget);
    expect(find.text('薄弱考点 TOP5'), findsOneWidget);
    expect(find.text('最近刷题记录'), findsOneWidget);
  });
}
