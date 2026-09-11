import 'package:dopa/app/theme/dopa_theme.dart';
import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa/app/presentation/dopa_components.dart';
import 'package:flutter/material.dart';

class DesignGalleryPage extends StatefulWidget {
  const DesignGalleryPage({super.key});
  @override
  State<DesignGalleryPage> createState() => _DesignGalleryPageState();
}

class _DesignGalleryPageState extends State<DesignGalleryPage> {
  bool dark = false, selected = true;
  @override
  Widget build(BuildContext context) => Theme(
    data: dark ? DopaTheme.dark : DopaTheme.light,
    child: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('디자인 시스템')),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(DopaSpacing.page(context)),
            children: [
              SwitchListTile(
                title: const Text('밤 정원 테마'),
                value: dark,
                onChanged: (v) => setState(() => dark = v),
              ),
              Text(
                '조금 쉬고, 다시 시작해요.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 16),
              const Text('본문은 작고 흐릿하지 않게. 한 번에 하나의 행동을 제안해요.'),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final c in [
                    Theme.of(context).colorScheme.primary,
                    DopaSurfaces.of(context).soft,
                    DopaSurfaces.of(context).sunlight,
                    DopaSurfaces.of(context).apricot,
                  ])
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              DopaActionButton(label: '같이 시작하기', onPressed: () {}),
              const SizedBox(height: 12),
              const DopaActionButton(label: '준비 중', busy: true),
              const SizedBox(height: 12),
              const DopaActionButton(label: '비활성 상태'),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: () {}, child: const Text('1분 쉬어가기')),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  labelText: '원래 하려던 일',
                  hintText: '선택 사항',
                ),
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  labelText: '생년월일',
                  errorText: '날짜를 확인해 주세요.',
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('10분'),
                    selected: selected,
                    onSelected: (v) => setState(() => selected = v),
                  ),
                  const ChoiceChip(label: Text('25분'), selected: false),
                ],
              ),
              const SizedBox(height: 24),
              const DopaStep(index: 0, total: 4, text: '작은 물건 하나를 옆으로 옮겨볼까요?'),
              const DopaRecordRow(
                title: '책상 한 칸 비우기',
                subtitle: '조금 시작했어요',
                icon: Icons.spa_outlined,
              ),
              const DopaNotice(message: '아직 기록이 없어요. 작은 시작부터 남겨봐요.'),
              DopaNotice(
                message: '기록을 저장하지 못했어요.',
                isError: true,
                onRetry: () {},
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
