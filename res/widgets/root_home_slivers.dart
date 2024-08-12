import 'package:flutter/material.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/theme.dart';

class RootHomeSlivers extends StatelessWidget {

  final VoidCallback onTapToRootPlace;
  final VoidCallback onTapToRootUsers;
  final VoidCallback onTapToUnitedPosition;
  final VoidCallback onTapToOwnerSearch;
  final VoidCallback onTapToPurchaseList;
  final VoidCallback onTapToStatistics;

  const RootHomeSlivers({
    super.key,
    required this.onTapToRootPlace,
    required this.onTapToRootUsers,
    required this.onTapToUnitedPosition,
    required this.onTapToOwnerSearch,
    required this.onTapToPurchaseList,
    required this.onTapToStatistics,


  });

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return SliverList(
      delegate: SliverChildListDelegate([

        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onTapToRootUsers,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      height: 100.0,
                      decoration: BoxDecoration(
                          border: Border.all(width: 2,color: Theme.of(context).primaryColor),
                          borderRadius: const BorderRadius.all(Radius.circular(10.0))
                      ),
                      child: Center(child: Text('Сотрудники',style: styles.worningTextStyle,)),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: onTapToRootPlace,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      height: 100.0,
                      decoration: BoxDecoration(
                          border: Border.all(width: 2,color: Theme.of(context).primaryColor),
                          borderRadius: const BorderRadius.all(Radius.circular(10.0))
                      ),
                      child: Center(child: Text('Объекты',style: styles.worningTextStyle,)),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onTapToStatistics,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      height: 100.0,
                      decoration: BoxDecoration(
                          border: Border.all(width: 2,color: Theme.of(context).primaryColor),
                          borderRadius: const BorderRadius.all(Radius.circular(10.0))
                      ),
                      child: Center(child: Text('Поставщики',style: styles.worningTextStyle,)),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: onTapToOwnerSearch,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      height: 100.0,
                      decoration: BoxDecoration(
                          border: Border.all(width: 2,color: Theme.of(context).primaryColor),
                          borderRadius: const BorderRadius.all(Radius.circular(10.0))
                      ),
                      child: Center(child: Text('Склад',style: styles.worningTextStyle,)),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: (){},
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      height: 100.0,
                      decoration: BoxDecoration(
                          border: Border.all(width: 2,color: Theme.of(context).primaryColor),
                          borderRadius: const BorderRadius.all(Radius.circular(10.0))
                      ),
                      child: Center(child: Text('Налоги',style: styles.worningTextStyle,)),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: onTapToUnitedPosition,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      height: 100.0,
                      decoration: BoxDecoration(
                          border: Border.all(width: 2,color: Theme.of(context).primaryColor),
                          borderRadius: const BorderRadius.all(Radius.circular(10.0))
                      ),
                      child: Center(child: Text('Объемы на закуп',style: styles.worningTextStyle,)),
                    ),
                  ),
                ),

              ],
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onTapToStatistics,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      height: 100.0,
                      decoration: BoxDecoration(
                          border: Border.all(width: 2,color: Theme.of(context).primaryColor),
                          borderRadius: const BorderRadius.all(Radius.circular(10.0))
                      ),
                      child: Center(child: Text('Статистика',style: styles.worningTextStyle,)),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: onTapToPurchaseList,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      height: 100.0,
                      decoration: BoxDecoration(
                          border: Border.all(width: 2,color: Theme.of(context).primaryColor),
                          borderRadius: const BorderRadius.all(Radius.circular(10.0))
                      ),
                      child: Center(child: Text('Мониторинг',style: styles.worningTextStyle,)),
                    ),
                  ),
                ),

              ],
            ),
          ],
        ),
        const SizedBox(height: 18.0,),
        Text('Руководство пользователя',textAlign: TextAlign.center, style: styles.addToCartPriceStyle,),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              RichSpanText(spanText: SnapTextModel(title: 'Создать магазин: ', data: 'Отметить на карте локацию точки отгрузки (для определения расстояния до точки доставки). '
                  'Добавить название магазина, сохраняем, после этого системой присваевается статус снабженца, далее добавляем позиции в ручную или загружаем excel документ.\n'
                  'Добавленные позиции опубликованы и доступны закзчикам \n'
                  'При поступлении заявок позиции сортируются по наменованиям, суммируются по количеству, формируется объем на закуп\n'
                  '', postTitle: ' --- ')),

              RichSpanText(spanText: SnapTextModel(title: 'Регистрация сотрудника: ', data: 'Для регистрации сотрудника надо открыть QR код, а кондидат в сотрудники (уже является зарегестрированным '
                  'пользователем) сканирует предоставленый QR код, таким образом происходит привязка пользователя к функционалу '
                  'магазина и становится сотрудником которому предстоит присвоить права в соответствии с обязаностями\n',postTitle: ' --- ')),

              RichSpanText(spanText: SnapTextModel(title: 'Обработка заказа: ', data: 'Закупщик, методом тапа выбирает позиции из сформированного списка объемы на закуп '
                  'после чего выбранные позиции переходят под ответственность закупщика.\n'
                  'В процессе закупа заносится фактическая цена и количество, по результату '
                  'корректируется цена на складе и количество в списке объем на закуп.\n'
                  'Следующий этап: сдача закупленных позиций на склад, заносится фактическое количество корректируются значения на складе и в закупе, '
                  'по результату, позиции переходят под ответственность склада.\n'
                  'Следующий этап: сортировка и фасовка заказа, заносится фактическое количество, так же на момент отгрузки цена позиций в заказе '
                  'корректируется по текущей фактической цене на складе (если на складе цена меньше чем по закупу), по результату отгруженные позиции переходят под ответственность доставщика\n'
                  'Следующий этап: доставка и сдача заказа клиенту. Клиент имеет возможность принять каждую позицию через весы , отказаться '
                  'по соответствующей причине, или принять все без проверки, в любом случае заносится фактическое количество, по результату статус заказа выполнен', postTitle: ' --- ')),

              RichSpanText(spanText: SnapTextModel(title: 'Оформление заказа: ', data: 'Выбор позиций для заказа, добавление в корзину (изменения деталей в корзине, одновременное заполнение корзин у разных поставщиков).'
                  'По завершению добавления жмем кнопку заказать, в случае если: пользователь не зарегестрирован? переход на страницу регистрации по номеру телефона '
                  'далее переход на страницу регистрации адреса, далее возврат на страницу корзина если надо добавляем или изменяем детали корзины жмем кнопку заказать, заказ успешно отправлен.', postTitle: ' --- ')),
            ],
          ),
        ),
      ]),
    );
  }
}
