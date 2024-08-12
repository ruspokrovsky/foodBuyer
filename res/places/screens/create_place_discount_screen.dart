import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/registration/user_prividers/user_providers.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/place_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/places/place_services/place_fb_services.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/cached_network_image.dart';
import 'package:ya_bazaar/res/widgets/edit_text.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/res/widgets/two_buttons_block.dart';
import 'package:ya_bazaar/theme.dart';

class CreatePlaceDiscountScreen extends StatefulWidget {
  static const routeName = 'createPlaceDiscountScreen';

  final UserModel userData;

  const CreatePlaceDiscountScreen({super.key, required this.userData});

  @override
  State<CreatePlaceDiscountScreen> createState() => _CreatePlaceDiscountScreenState();
}

class _CreatePlaceDiscountScreenState extends State<CreatePlaceDiscountScreen> {
  TextEditingController discountController = TextEditingController();
  TextEditingController limitController = TextEditingController();
  late UserModel userData;
  @override
  void initState() {
    userData = widget.userData;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    AppStyles styles = AppStyles.appStyle(context);

    return Scaffold(
      appBar: AppBar(title: Text('Установить кешбек', style: styles.appBarTitleTextStyle,),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              color: const Color.fromRGBO(255, 251, 230, 1),
              width: double.infinity,
              height: 100,
              child: Row(
                children: [
                  CachedNetworkImg(
                      imageUrl: userData.profilePhoto,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover),
                  const SizedBox(width: 8.0,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichSpanText(spanText: SnapTextModel(title: 'Имя клиента: ', data: userData.name, postTitle: '')),
                      RichSpanText(spanText: SnapTextModel(title: 'Текущий кешбек: ', data: userData.discountPercent.toString(), postTitle: ' %')),
                      RichSpanText(spanText: SnapTextModel(title: 'Статус: ', data: userData.userStatus.toString(), postTitle: '')),
                      RichSpanText(spanText: SnapTextModel(title: 'Зарегестрирован: ', data: Utils().dateParse(milliseconds: userData.addedAt!), postTitle: '')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0,),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: EditText(
                controller: discountController,
                textInputType: TextInputType.number,
                labelText: 'Установить % кешбек',
                onChanged: (v){},
              ),
            ),
            const SizedBox(height: 16.0,),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {

                return TwoButtonsBlock(
                    positiveText: 'Сохранить',
                    positiveClick: (){

                      PlaceFBServices()
                          .updatePlaceDiscount(
                          customerId: userData.uId,
                          rootId: ref.read(currentUserProvider).rootId.toString(),
                          discountPercent: num.parse(discountController.text.trim()))
                          .then((value) {

                        print(value);

                        Navigator.pop(context);


                      });
                    },
                    negativeText: 'Назад',
                    negativeClick: ()=> Navigator.pop(context));
              },
            ),
            const SizedBox(height: 16.0,),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: EditText(
                controller: limitController,
                textInputType: TextInputType.number,
                labelText: 'Установить лимит UZS',
                onChanged: (v){},
              ),
            ),
            const SizedBox(height: 16.0,),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {

                return TwoButtonsBlock(
                    positiveText: 'Сохранить',
                    positiveClick: (){

                      PlaceFBServices()
                          .updateLimit(
                          customerId: userData.uId,
                          rootId: ref.read(currentUserProvider).rootId.toString(),
                          limit: num.parse(limitController.text.trim()))
                      .then((value) {


                        Navigator.pop(context);


                      });
                    },
                    negativeText: 'Назад',
                    negativeClick: ()=> Navigator.pop(context));
              },
            ),
          ],
        ),
      ),
    );
  }
}
