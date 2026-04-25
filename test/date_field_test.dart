import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getdate_textfield/getdate_textfield.dart';

void main() {
  late DateTime firstDate;
  late DateTime lastDate;

  setUp(() {
    firstDate = DateTime(2000);
    lastDate = DateTime(2050, 12, 31);
  });

  /// Widget auxiliar para injetar o DateField na árvore de widgets do teste
  Widget buildTestableWidget({
    required DateFieldController controller,
    Function? onFinish,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: DateField(
            controller: controller,
            onFinishFunction: onFinish,
          ),
        ),
      ),
    );
  }

  group('DateField - Estado Inicial e Controller', () {
    testWidgets('1. Inicializa vazio quando initialValue é null',
        (tester) async {
      final controller =
          DateFieldController(firstDate: firstDate, lastDate: lastDate);
      await tester.pumpWidget(buildTestableWidget(controller: controller));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, isEmpty);
      expect(controller.value, isNull);
    });

    testWidgets('2. Inicializa com texto formatado quando tem initialValue',
        (tester) async {
      final initial = DateTime(2024, 4, 15);
      final controller = DateFieldController(
        firstDate: firstDate,
        lastDate: lastDate,
        initialValue: initial,
      );

      await tester.pumpWidget(buildTestableWidget(controller: controller));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, '15/04/2024');
      expect(controller.value, equals(initial));
    });

    testWidgets('3. controller.setValue atualiza a interface visual',
        (tester) async {
      final controller =
          DateFieldController(firstDate: firstDate, lastDate: lastDate);
      await tester.pumpWidget(buildTestableWidget(controller: controller));

      controller.setValue(DateTime(2025, 12, 25));
      await tester.pump(); // Atualiza a UI

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, '25/12/2025');
    });
  });

  group('DateField - Entrada de Texto e Validação', () {
    testWidgets(
        '4. Máscara formata digitação corretamente (DDMMYYYY -> DD/MM/YYYY)',
        (tester) async {
      final controller =
          DateFieldController(firstDate: firstDate, lastDate: lastDate);
      await tester.pumpWidget(buildTestableWidget(controller: controller));

      await tester.enterText(find.byType(TextField), '10102020');
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, '10/10/2020');
    });

    testWidgets('5. Digitar data válida atualiza o controller após o debounce',
        (tester) async {
      final controller =
          DateFieldController(firstDate: firstDate, lastDate: lastDate);
      await tester.pumpWidget(buildTestableWidget(controller: controller));

      await tester.enterText(find.byType(TextField), '12/12/2024');

      // Aguarda o tempo do debounce configurado no controller (padrão 120ms)
      await tester.pump(const Duration(milliseconds: 150));

      expect(controller.value, DateTime(2024, 12, 12));
      expect(controller.errorText, isNull);
    });

    testWidgets('6. Digitar data inválida (formato) gera erro após debounce',
        (tester) async {
      final controller =
          DateFieldController(firstDate: firstDate, lastDate: lastDate);
      await tester.pumpWidget(buildTestableWidget(controller: controller));

      await tester.enterText(find.byType(TextField), '99/99/9999');
      await tester.pump(const Duration(milliseconds: 150));

      expect(controller.value, isNull);
      expect(controller.errorText,
          isNotNull); // Deve ter mensagem de 'invalidFormat'
    });

    testWidgets('7. Digitar data fora do intervalo (outOfRange) gera erro',
        (tester) async {
      final controller =
          DateFieldController(firstDate: firstDate, lastDate: lastDate);
      await tester.pumpWidget(buildTestableWidget(controller: controller));

      // 1999 está fora do firstDate (2000)
      await tester.enterText(find.byType(TextField), '01/01/1999');
      await tester.pump(const Duration(milliseconds: 150));

      expect(controller.value,
          isNull); // Ou valor base dependendo da sua regra de negócio
      expect(controller.errorText, isNotNull);
    });
  });

  group('DateField - Interação com Overlay (Calendário)', () {
    testWidgets('8. Focar no campo abre o overlay do calendário',
        (tester) async {
      final controller =
          DateFieldController(firstDate: firstDate, lastDate: lastDate);
      await tester.pumpWidget(buildTestableWidget(controller: controller));

      // Toca para dar foco
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.byType(CalendarDatePicker), findsOneWidget);
      expect(controller.overlayPortalController.isShowing, isTrue);
    });

    testWidgets('9. Tocar no ícone ou campo quando não tem foco abre overlay',
        (tester) async {
      final controller =
          DateFieldController(firstDate: firstDate, lastDate: lastDate);
      await tester.pumpWidget(buildTestableWidget(controller: controller));

      controller.openOverlay(tester.element(find.byType(TextField)));
      await tester.pumpAndSettle();

      expect(find.byType(CalendarDatePicker), findsOneWidget);
    });

    testWidgets(
        '10. Selecionar uma data no calendário atualiza o valor e fecha overlay',
        (tester) async {
      final controller = DateFieldController(
        firstDate: firstDate,
        lastDate: lastDate,
        initialValue: DateTime(2024),
      );
      await tester.pumpWidget(buildTestableWidget(controller: controller));

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Toca no dia 15 do mês atual exibido no calendário
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(find.byType(CalendarDatePicker), findsNothing); // Fechou
      expect(controller.value!.day, 15);
      expect(controller.overlayPortalController.isShowing, isFalse);
    });

    testWidgets('11. Tocar fora do calendário fecha o overlay', (tester) async {
      final controller =
          DateFieldController(firstDate: firstDate, lastDate: lastDate);
      await tester.pumpWidget(buildTestableWidget(controller: controller));

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarDatePicker), findsOneWidget);

      // Toca no canto superior esquerdo (fora do calendário)
      await tester.tapAt(const Offset(1, 1));
      await tester.pumpAndSettle();

      expect(find.byType(CalendarDatePicker), findsNothing);
    });
  });

  group('DateField - Teclado e Eventos Físicos', () {
    testWidgets('12. Pressionar ESC fecha o overlay', (tester) async {
      final controller =
          DateFieldController(firstDate: firstDate, lastDate: lastDate);
      await tester.pumpWidget(buildTestableWidget(controller: controller));

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Pressiona Esc
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(CalendarDatePicker), findsNothing);
    });

    testWidgets(
        '13. Pressionar ENTER dispara handleSubmit, valida e chama onFinish',
        (tester) async {
      bool onFinishCalled = false;
      final controller =
          DateFieldController(firstDate: firstDate, lastDate: lastDate);
      await tester.pumpWidget(
        buildTestableWidget(
          controller: controller,
          onFinish: () => onFinishCalled = true,
        ),
      );

      await tester.enterText(find.byType(TextField), '10/10/2020');
      // Pressiona Enter
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(onFinishCalled, isTrue);
      expect(controller.value, DateTime(2020, 10, 10));
      expect(
          find.byType(CalendarDatePicker), findsNothing); // Deve fechar overlay
    });

    testWidgets('14. Pressionar TAB dispara handleSubmit e valida a data',
        (tester) async {
      bool onFinishCalled = false;
      final controller =
          DateFieldController(firstDate: firstDate, lastDate: lastDate);
      await tester.pumpWidget(
        buildTestableWidget(
          controller: controller,
          onFinish: () => onFinishCalled = true,
        ),
      );

      await tester.enterText(find.byType(TextField), '20/05/2021');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(onFinishCalled, isTrue);
      expect(controller.value, DateTime(2021, 5, 20));
    });
  });

  group('DateField - Ciclo de Vida', () {
    testWidgets('15. didUpdateWidget reconecta o novo controller corretamente',
        (tester) async {
      final controller1 =
          DateFieldController(firstDate: firstDate, lastDate: lastDate);
      final controller2 =
          DateFieldController(firstDate: firstDate, lastDate: lastDate);

      // Constrói com controller 1
      await tester.pumpWidget(buildTestableWidget(controller: controller1));

      // Reconstrói a árvore substituindo pelo controller 2
      await tester.pumpWidget(buildTestableWidget(controller: controller2));

      // Digita algo para validar que o controller2 está escutando
      await tester.enterText(find.byType(TextField), '01/01/2030');
      await tester.pump(const Duration(milliseconds: 150));

      expect(controller1.value, isNull); // Antigo não muda
      expect(controller2.value, DateTime(2030)); // Novo mudou
    });

    testWidgets(
        '16. Dispose do widget executa detach e limpa listeners com segurança',
        (tester) async {
      final controller =
          DateFieldController(firstDate: firstDate, lastDate: lastDate);

      // Pump no widget
      await tester.pumpWidget(buildTestableWidget(controller: controller));

      // Remove o widget da árvore (forçando dispose)
      await tester.pumpWidget(const SizedBox());

      // Se o detach foi chamado sem erros, podemos fazer update no controller e ele não
      // tentará atualizar widgets "mortos".
      expect(() => controller.setValue(DateTime.now()), returnsNormally);
    });
  });

  group('DateField - Atualizações Dinâmicas e Recuperação de Erro', () {
    testWidgets('17. controller.setText insere o texto e agenda validação',
        (tester) async {
      final controller =
          DateFieldController(firstDate: firstDate, lastDate: lastDate);
      await tester.pumpWidget(buildTestableWidget(controller: controller));

      // Chama setText diretamente
      controller.setText('25/12/2025');
      
      // O texto deve atualizar na UI imediatamente
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, '25/12/2025');

      // O valor (DateTime) só atualiza após o debounce
      expect(controller.value, isNull);
      await tester.pump(const Duration(milliseconds: 150));
      expect(controller.value, DateTime(2025, 12, 25));
    });

    testWidgets('18. Digitar data válida após uma inválida limpa o erro',
        (tester) async {
      final controller =
          DateFieldController(firstDate: firstDate, lastDate: lastDate);
      await tester.pumpWidget(buildTestableWidget(controller: controller));

      // 1. Digita data inválida
      await tester.enterText(find.byType(TextField), '99/99/9999');
      await tester.pump(const Duration(milliseconds: 150));
      expect(controller.errorText, isNotNull); // Erro presente

      // 2. Apaga e digita data válida
      await tester.enterText(find.byType(TextField), '01/01/2025');
      await tester.pump(const Duration(milliseconds: 150));
      
      expect(controller.errorText, isNull); // Erro deve ter sido limpo
      expect(controller.value, DateTime(2025));
    });

    testWidgets('19. Alterar setRange revalida o valor atual dinamicamente',
        (tester) async {
      // Inicia com uma data válida (2025) e range até 2050
      final controller = DateFieldController(
        firstDate: firstDate,
        lastDate: lastDate,
        initialValue: DateTime(2025),
      );
      await tester.pumpWidget(buildTestableWidget(controller: controller));
      expect(controller.errorText, isNull);

      // Altera o range fazendo com que o limite máximo seja 2024 (deixando 2025 inválido)
      controller.setRange(first: firstDate, last: DateTime(2024, 12, 31));
      
      // Como setRange chama validateNow() internamente, o erro deve aparecer instantaneamente
      expect(controller.errorText, isNotNull); 
    });
  });

  group('DateField - Customização e Comportamentos Ocultos', () {
    testWidgets('20. decorationBuilder customizado substitui o visual padrão',
        (tester) async {
      final controller =
          DateFieldController(firstDate: firstDate, lastDate: lastDate);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateField(
              controller: controller,
              decorationBuilder: (context, errorText, textController) {
                return InputDecoration(
                  labelText: 'Meu Label Customizado',
                  errorText: errorText == null ? null : 'Ops, erro!',
                );
              },
            ),
          ),
        ),
      );

      // Verifica se a label customizada foi aplicada
      expect(find.text('Meu Label Customizado'), findsOneWidget);

      // Força um erro para ver se a string customizada "Ops, erro!" aparece
      await tester.enterText(find.byType(TextField), '99/99/9999');
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Ops, erro!'), findsOneWidget);
    });

    testWidgets('21. closeOverlay() manual do controller fecha o calendário',
        (tester) async {
      final controller =
          DateFieldController(firstDate: firstDate, lastDate: lastDate);
      await tester.pumpWidget(buildTestableWidget(controller: controller));

      // Abre o overlay
      controller.openOverlay(tester.element(find.byType(TextField)));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarDatePicker), findsOneWidget);

      // Chama o método direto do controller
      controller.closeOverlay();
      await tester.pumpAndSettle();

      // Verifica se fechou
      expect(find.byType(CalendarDatePicker), findsNothing);
    });

    testWidgets('22. Após submit, bounce de foco imediato não reabre o calendário',
        (tester) async {
      final controller =
          DateFieldController(firstDate: firstDate, lastDate: lastDate);
      await tester.pumpWidget(buildTestableWidget(controller: controller));

      // Foca e digita
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '10/10/2020');
      
      // Envia Enter. Isso aciona handleSubmit, tira o foco e ativa a trava (_justSubmitted = true)
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      
      // IMEDIATAMENTE forçamos o foco de volta programaticamente ANTES do frame virar.
      // Isso simula o comportamento anômalo do sistema que a trava _justSubmitted tenta evitar.
      tester.widget<TextField>(find.byType(TextField)).focusNode?.requestFocus();
      
      // Avançamos o frame (sem usar pumpAndSettle para não estourar o tempo da trava)
      await tester.pump();

      // O overlay NÃO deve ter sido aberto!
      expect(controller.overlayPortalController.isShowing, isFalse);
    });
  });
}
