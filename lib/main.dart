import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const EasyYanApp());
}

class EasyYanApp extends StatelessWidget {
  const EasyYanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '考研数学刷题系统',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamilyFallback: const ['PingFang SC', 'Microsoft YaHei', 'Arial'],
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.bg,
        filledButtonTheme: const FilledButtonThemeData(
          style: ButtonStyle(
            mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.click),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: const ButtonStyle(
            mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.click),
          ),
        ),
      ),
      initialRoute: AppRoute.home.path,
      onGenerateRoute: (settings) {
        final route = AppRoute.match(settings.name ?? AppRoute.home.path);
        return PageRouteBuilder<void>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              Shell(route: route),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    );
  }
}

class AppColors {
  static const primary = Color(0xFF1F53FF);
  static const primarySoft = Color(0xFFEFF3FF);
  static const ink = Color(0xFF07164A);
  static const text = Color(0xFF18275D);
  static const muted = Color(0xFF7380A7);
  static const line = Color(0xFFE5EAF7);
  static const bg = Color(0xFFF8FAFF);
  static const surface = Color(0xFFFFFFFF);
  static const green = Color(0xFF18B979);
  static const orange = Color(0xFFFF9B21);
  static const red = Color(0xFFFF5B63);
  static const violet = Color(0xFF8E5BFF);
  static const teal = Color(0xFF2DC6B7);
}

enum AppRoute {
  home('/', '首页', Icons.home_rounded),
  textbook('/textbooks', '教材库', Icons.menu_book_rounded),
  questions('/questions', '习题库', Icons.article_outlined),
  papers('/papers', '试卷库', Icons.assignment_outlined),
  practice('/practice', '刷题', Icons.fact_check_outlined),
  mistakes('/mistakes', '错题集', Icons.grid_view_rounded),
  favorites('/favorites', '收藏夹', Icons.star_border_rounded),
  analytics('/analytics', '统计分析', Icons.bar_chart_rounded),
  knowledge('/knowledge', '知识网络', Icons.hub_outlined),
  plans('/plans', '学习计划', Icons.event_available_outlined),
  notes('/notes', '笔记管理', Icons.edit_note_rounded),
  settings('/settings', '设置', Icons.settings_outlined);

  const AppRoute(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;

  static AppRoute match(String path) {
    return values.firstWhere((route) => route.path == path, orElse: () => home);
  }
}

class Shell extends StatelessWidget {
  const Shell({super.key, required this.route});

  final AppRoute route;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        body: Row(
          children: [
            Sidebar(activeRoute: route),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentWidth = math.max(constraints.maxWidth, 1536.0);
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: contentWidth,
                      child: Column(
                        children: [
                          TopBar(route: route),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                28,
                                22,
                                28,
                                28,
                              ),
                              child: route == AppRoute.home
                                  ? const HomePage()
                                  : PlaceholderPage(route: route),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  const Sidebar({super.key, required this.activeRoute});

  final AppRoute activeRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 238,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Brand(),
              const SizedBox(height: 26),
              Expanded(
                child: ListView.separated(
                  itemCount: AppRoute.values.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final route = AppRoute.values[index];
                    return NavItem(
                      route: route,
                      selected: route == activeRoute,
                    );
                  },
                ),
              ),
              const StudySummaryCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class Brand extends StatelessWidget {
  const Brand({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(7),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: .22),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Text(
            'UR',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          '考研数学刷题系统',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class NavItem extends StatelessWidget {
  const NavItem({super.key, required this.route, required this.selected});

  final AppRoute route;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      mouseCursor: SystemMouseCursors.click,
      hoverColor: AppColors.primarySoft.withValues(alpha: .65),
      onTap: () {
        if (!selected) {
          Navigator.of(context).pushReplacementNamed(route.path);
        }
      },
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              route.icon,
              size: 22,
              color: selected ? AppColors.primary : AppColors.muted,
            ),
            const SizedBox(width: 13),
            Text(
              route.label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.text,
                fontSize: 16,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.route});

  final AppRoute route;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              route == AppRoute.home ? '首页 / 学习概览' : route.label,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SearchBox(),
          const SizedBox(width: 20),
          const NotificationIcon(),
          const SizedBox(width: 16),
          const Icon(Icons.mail_outline_rounded, color: AppColors.text),
          const SizedBox(width: 20),
          const UserBadge(),
        ],
      ),
    );
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 20, color: AppColors.muted),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '搜索题目、考点、教材等...',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.muted, fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4FB),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '⌘ K',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_none_rounded, color: AppColors.text),
        Positioned(
          right: -4,
          top: -8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '12',
              style: TextStyle(color: Colors.white, fontSize: 9),
            ),
          ),
        ),
      ],
    );
  }
}

class UserBadge extends StatelessWidget {
  const UserBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFFE7EBF5),
          child: Icon(Icons.person_rounded, color: AppColors.text, size: 20),
        ),
        const SizedBox(width: 10),
        const Text(
          '奔跑的数学人',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Text(
            'Lv.5',
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class StudySummaryCard extends StatelessWidget {
  const StudySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '学习概况',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          const MetricLine(label: '累计学习', value: '128', unit: '天'),
          const Divider(height: 26, color: AppColors.line),
          const Row(
            children: [
              Expanded(
                child: MetricLine(label: '连续学习', value: '15', unit: '天'),
              ),
              Expanded(
                child: MetricLine(label: '今日学习', value: '68', unit: '分钟'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.event_available_rounded),
              label: const Text('打卡学习'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primarySoft,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MetricLine extends StatelessWidget {
  const MetricLine({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 7),
        RichText(
          text: TextSpan(
            text: value,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
            children: [
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        StatGrid(),
        SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 11, child: TodayTaskCard()),
            SizedBox(width: 16),
            Expanded(flex: 10, child: WeakPointsCard()),
            SizedBox(width: 16),
            Expanded(flex: 10, child: CalendarCard()),
          ],
        ),
        SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 16, child: RecentPracticeCard()),
            SizedBox(width: 16),
            Expanded(flex: 10, child: RightColumn()),
          ],
        ),
      ],
    );
  }
}

class StatGrid extends StatelessWidget {
  const StatGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      StatData(
        Icons.assignment_rounded,
        '刷题总量',
        '12,560',
        '题',
        '较昨日 +320',
        AppColors.primary,
      ),
      StatData(
        Icons.playlist_add_check_rounded,
        '正确数量',
        '9,256',
        '题',
        '较昨日 +210',
        AppColors.green,
      ),
      StatData(
        Icons.verified_rounded,
        '正确率',
        '73.7',
        '%',
        '较昨日 +2.1%',
        AppColors.orange,
      ),
      StatData(
        Icons.disabled_by_default_rounded,
        '错题数量',
        '1,842',
        '题',
        '较昨日 +45',
        AppColors.red,
      ),
      StatData(
        Icons.trending_up_rounded,
        '掌握考点',
        '128',
        '个',
        '总考点 256 个',
        AppColors.violet,
      ),
    ];

    return Row(
      children: [
        for (final stat in stats) ...[
          Expanded(child: StatCard(data: stat)),
          if (stat != stats.last) const SizedBox(width: 14),
        ],
      ],
    );
  }
}

class StatData {
  const StatData(
    this.icon,
    this.label,
    this.value,
    this.unit,
    this.delta,
    this.color,
  );

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final String delta;
  final Color color;
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.data});

  final StatData data;

  @override
  Widget build(BuildContext context) {
    return Panel(
      height: 154,
      child: Row(
        children: [
          SoftIcon(icon: data.icon, color: data.color),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: const TextStyle(color: AppColors.muted, fontSize: 14),
                ),
                const SizedBox(height: 9),
                RichText(
                  text: TextSpan(
                    text: data.value,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                    children: [
                      TextSpan(
                        text: ' ${data.unit}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  data.delta,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TodayTaskCard extends StatelessWidget {
  const TodayTaskCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Panel(
      height: 390,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: '今日任务',
            trailing: Row(
              children: [
                Icon(
                  Icons.radio_button_checked_rounded,
                  size: 16,
                  color: AppColors.muted,
                ),
                SizedBox(width: 6),
                Text('目标：完成 50 题', style: TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              const DonutChart(
                size: 142,
                thickness: 14,
                values: [70, 30],
                colors: [AppColors.primary, Color(0xFFEFF2F8)],
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '70%',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text('已完成', style: TextStyle(color: AppColors.muted)),
                  ],
                ),
              ),
              const SizedBox(width: 42),
              Expanded(
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TaskMeta(label: '已完成', value: '35', unit: '题'),
                        TaskMeta(label: '剩余', value: '15', unit: '题'),
                        TaskMeta(label: '预计耗时', value: '40', unit: '分钟'),
                      ],
                    ),
                    const SizedBox(height: 34),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: .7,
                        minHeight: 9,
                        color: AppColors.primary,
                        backgroundColor: Color(0xFFECEFF7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          const Divider(color: AppColors.line),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: Text(
                  '每日任务将在 23:59:59 后重置',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
              SizedBox(
                height: 42,
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: const Text('去刷题'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TaskMeta extends StatelessWidget {
  const TaskMeta({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            text: value,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
            children: [
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WeakPointsCard extends StatelessWidget {
  const WeakPointsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('1', '多元函数微分学', '32%'),
      ('2', '特征值与特征向量', '45%'),
      ('3', '二重积分', '58%'),
      ('4', '微分方程求解', '63%'),
      ('5', '曲线积分与曲面积分', '68%'),
    ];

    return Panel(
      height: 390,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: '薄弱考点 TOP5',
            trailing: Text(
              '全部考点',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  RankBadge(rank: row.$1),
                  const SizedBox(width: 18),
                  Expanded(
                    flex: 8,
                    child: Text(
                      row.$2,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: int.parse(row.$3.replaceAll('%', '')) / 100,
                        minHeight: 5,
                        color: row.$1 == '1'
                            ? AppColors.red
                            : row.$1 == '2'
                            ? AppColors.orange
                            : AppColors.green,
                        backgroundColor: const Color(0xFFECEFF7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 42,
                    child: Text(
                      row.$3,
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class CalendarCard extends StatelessWidget {
  const CalendarCard({super.key});

  @override
  Widget build(BuildContext context) {
    const days = [
      '29',
      '30',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
      '13',
      '14',
      '15',
      '16',
      '17',
      '18',
      '19',
      '20',
      '21',
      '22',
      '23',
      '24',
      '25',
      '26',
      '27',
      '28',
      '29',
      '30',
      '31',
      '1',
      '2',
    ];

    return Panel(
      height: 390,
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          const SectionTitle(
            title: '学习日历',
            trailing: Text(
              '2024年5月 〉',
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Weekday('一'),
              Weekday('二'),
              Weekday('三'),
              Weekday('四'),
              Weekday('五'),
              Weekday('六'),
              Weekday('日'),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 36,
            ),
            itemBuilder: (_, index) {
              final active = days[index] == '12' && index == 13;
              final muted = index < 2 || index > 32;
              return Center(
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: active
                      ? const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        )
                      : null,
                  child: Text(
                    days[index],
                    style: TextStyle(
                      color: active
                          ? Colors.white
                          : muted
                          ? const Color(0xFFA9B3CC)
                          : AppColors.ink,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
          const Spacer(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LegendDot(color: Color(0xFFC7CDDA), label: '未学习'),
              SizedBox(width: 22),
              LegendDot(color: AppColors.orange, label: '学习中'),
              SizedBox(width: 22),
              LegendDot(color: AppColors.green, label: '已完成'),
            ],
          ),
        ],
      ),
    );
  }
}

class RecentPracticeCard extends StatelessWidget {
  const RecentPracticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    const rows = [
      (
        '章节练习',
        '高等数学 · 第五章 一元函数积分学',
        '30 题',
        '76%',
        '今天 10:24',
        '继续练习',
        AppColors.primary,
      ),
      (
        '考点练习',
        '中值定理与导数的应用',
        '20 题',
        '65%',
        '昨天 16:45',
        '继续练习',
        AppColors.green,
      ),
      (
        '试卷练习',
        '2023年考研数学一真题',
        '33 题',
        '71%',
        '05-11 09:15',
        '查看报告',
        AppColors.orange,
      ),
      (
        '错题重做',
        '错题集（共 128 题）',
        '15 题',
        '80%',
        '05-10 14:30',
        '继续练习',
        AppColors.red,
      ),
    ];

    return Panel(
      height: 420,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
      child: Column(
        children: [
          const SectionTitle(
            title: '最近刷题记录',
            trailing: Text(
              '查看全部',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFCFF),
              border: Border.all(color: AppColors.line),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(width: 96, child: TableHead('类型')),
                Expanded(child: TableHead('内容')),
                SizedBox(width: 90, child: TableHead('题量')),
                SizedBox(width: 90, child: TableHead('正确率')),
                SizedBox(width: 110, child: TableHead('时间')),
                SizedBox(width: 90, child: TableHead('操作')),
              ],
            ),
          ),
          for (final row in rows)
            Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.line)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 96,
                    child: ChipLabel(text: row.$1, color: row.$7),
                  ),
                  Expanded(
                    child: Text(
                      row.$2,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Text(
                      row.$3,
                      style: const TextStyle(color: AppColors.text),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Text(
                      row.$4,
                      style: const TextStyle(color: AppColors.text),
                    ),
                  ),
                  SizedBox(
                    width: 110,
                    child: Text(
                      row.$5,
                      style: const TextStyle(color: AppColors.text),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Text(
                      row.$6,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class RightColumn extends StatelessWidget {
  const RightColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [MasteryCard(), SizedBox(height: 16), SuggestionCard()],
    );
  }
}

class MasteryCard extends StatelessWidget {
  const MasteryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Panel(
      height: 210,
      padding: EdgeInsets.all(22),
      child: Row(
        children: [
          DonutChart(
            size: 120,
            thickness: 18,
            values: [34, 40, 18, 8],
            colors: [
              AppColors.green,
              AppColors.orange,
              AppColors.red,
              Color(0xFFC6CDD9),
            ],
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '256',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
                Text(
                  '总考点',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(width: 26),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LegendDot(
                  color: AppColors.green,
                  label: '掌握牢固       88 个 (34%)',
                ),
                SizedBox(height: 13),
                LegendDot(
                  color: AppColors.orange,
                  label: '掌握一般      102 个 (40%)',
                ),
                SizedBox(height: 13),
                LegendDot(color: AppColors.red, label: '掌握薄弱       46 个 (18%)'),
                SizedBox(height: 13),
                LegendDot(
                  color: Color(0xFFC6CDD9),
                  label: '未开始         20 个 (8%)',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SuggestionCard extends StatelessWidget {
  const SuggestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Panel(
      height: 210,
      padding: const EdgeInsets.all(22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SoftIcon(
            icon: Icons.lightbulb_outline_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        '学习建议',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: AppColors.text,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  '坚持真题训练，查漏补缺',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '根据你的学习数据分析，建议加强“多元函数微分学”的练习，巩固基础知识，提升整体正确率。',
                  style: TextStyle(color: AppColors.muted, height: 1.5),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: const Text('去练习薄弱考点'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.route});

  final AppRoute route;

  @override
  Widget build(BuildContext context) {
    return Panel(
      height: 520,
      padding: const EdgeInsets.all(36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            route.label,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '页面路由已接入，后续将按照原型图继续完善该模块。',
            style: TextStyle(color: AppColors.muted, fontSize: 16),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () {},
                icon: Icon(route.icon),
                label: Text('进入${route.label}流程'),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(
                  context,
                ).pushReplacementNamed(AppRoute.home.path),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('返回首页'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B4A77).withValues(alpha: .04),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SoftIcon extends StatelessWidget {
  const SoftIcon({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }
}

class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.size,
    required this.thickness,
    required this.values,
    required this.colors,
    required this.center,
  });

  final double size;
  final double thickness;
  final List<double> values;
  final List<Color> colors;
  final Widget center;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: DonutPainter(
              values: values,
              colors: colors,
              thickness: thickness,
            ),
          ),
          center,
        ],
      ),
    );
  }
}

class DonutPainter extends CustomPainter {
  DonutPainter({
    required this.values,
    required this.colors,
    required this.thickness,
  });

  final List<double> values;
  final List<Color> colors;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, value) => sum + value);
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.butt;
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * math.pi * 2;
      paint.color = colors[i % colors.length];
      canvas.drawArc(rect.deflate(thickness / 2), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant DonutPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors;
  }
}

class RankBadge extends StatelessWidget {
  const RankBadge({super.key, required this.rank});

  final String rank;

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.red,
      AppColors.orange,
      AppColors.orange,
      const Color(0xFFB9C0D2),
      const Color(0xFFB9C0D2),
    ];
    final index = int.parse(rank) - 1;
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors[index],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        rank,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class LegendDot extends StatelessWidget {
  const LegendDot({super.key, required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: AppColors.text, fontSize: 13),
        ),
      ],
    );
  }
}

class Weekday extends StatelessWidget {
  const Weekday(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: AppColors.muted, fontSize: 12),
    );
  }
}

class TableHead extends StatelessWidget {
  const TableHead(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.muted,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class ChipLabel extends StatelessWidget {
  const ChipLabel({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
