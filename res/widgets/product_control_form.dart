import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ya_bazaar/res/widgets/cached_network_image.dart';
import 'package:ya_bazaar/res/widgets/edit_text.dart';
import 'package:ya_bazaar/res/widgets/local_switch.dart';
import 'package:ya_bazaar/res/widgets/two_buttons_block.dart';
import 'package:ya_bazaar/theme.dart';

class ProductControlForm extends StatelessWidget {
  final String whoScreen;

  final TextEditingController actualQtyController;
  final TextEditingController actualPriceController;
  final TextEditingController descriptionController;
  final VoidCallback? positiveClick;
  final VoidCallback? neutralClick;
  final VoidCallback? negativeClick;
  final String strAmount;
  final String? positiveText;
  final String? neutralText;
  final String? negativeText;
  final String strProductName;
  final String strSelectedQty;
  final String productMeasure;
  final String positionPrice;
  final String strPositionPrice;
  final String imageUrl;
  final String strQtyTitle;

  final Function onChangedPrice;
  final Function onChangedQuantity;
  final bool? isNdsStatus;
  final Function? toggleNdsStatus;
  final Widget? bottom;


  const ProductControlForm({
    super.key,
    required this.whoScreen,
    required this.actualQtyController,
    required this.actualPriceController,
    required this.descriptionController,
    this.positiveText,
    this.positiveClick,
    this.neutralText,
    this.neutralClick,
    this.negativeText,
    this.negativeClick,
    required this.strAmount,
    required this.strProductName,
    required this.strSelectedQty,
    required this.productMeasure,
    required this.positionPrice,
    required this.strPositionPrice,
    required this.imageUrl,
    required this.strQtyTitle,

    required this.onChangedPrice,
    required this.onChangedQuantity,
    this.isNdsStatus,
    this.toggleNdsStatus,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {

   AppStyles styles = AppStyles.appStyle(context);

    return Column(
      children: [

        Text(strProductName, textAlign: TextAlign.center,
          softWrap: true,
          style: styles.addToCartPriceStyle,),

        const SizedBox(height: 8.0,),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: strQtyTitle,
                style: TextStyle(fontSize:18,color: Theme.of(context).primaryColor),
                children: <TextSpan>[
                  TextSpan(text: strSelectedQty),
                  TextSpan(text: ' $productMeasure'),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                text: strPositionPrice,
                style: TextStyle(fontSize:18,color: Theme.of(context).primaryColor),
                children: <TextSpan>[
                  TextSpan(text: positionPrice),
                  const TextSpan(text: ' /UZS'),
                ],
              ),
            ),
          ],
        ),


        const SizedBox(
          height: 20.0,
        ),
        EditText(
          labelText: 'Количество по факту',
          controller: actualQtyController,
          textInputType: TextInputType.number,
          textStyle: styles.addToCartPriceStyle,
          onTapEditText: () {},
          onChanged: (value) => onChangedQuantity(value),
        ),
        const SizedBox(
          height: 20.0,
        ),
        if(whoScreen != 'acceptPositionScreen')
        Row(
          children: [
            Expanded(
              child: EditText(
                labelText: 'Цена по факту',
                controller: actualPriceController,
                textInputType: TextInputType.number,
                textStyle: styles.addToCartPriceStyle,
                onTapEditText: () {},
                onChanged: (value) => onChangedPrice(value),
              ),
            ),
            const SizedBox(width: 6.0,),

            Expanded(
              child: LocalSwitch(
                value: isNdsStatus!,
                activeText: "Купить с НДС",
                inactiveText: "Купить без НДС",
                onToggle: (v)=> toggleNdsStatus!(v),
              ),
            ),
          ]
        ),


        const SizedBox(height: 20.0,),

        RichText(
          text: TextSpan(
            text: 'Сумма: ',
            style: TextStyle(fontSize:20.0,color: Theme.of(context).primaryColor),
            children: <TextSpan>[
              TextSpan(text: strAmount,style: const TextStyle(color: Colors.deepOrange)),
              const TextSpan(text: ' UZS'),
            ],
          ),
        ),


        const SizedBox(height: 20.0,),
        EditText(
          controller: descriptionController,
          maxLines: 4,
          labelText: 'Примечание',
          textStyle: Theme.of(context).textTheme.bodyMedium,
          borderRadius: 10.0,
          onChanged: (value) {},
        ),
        const SizedBox(
          height: 20.0,
        ),
        // TwoButtonsBlock(
        //     negativeClick: negativeClick!,
        //     positiveClick: positiveClick!,
        //     negativeText: negativeText!,
        //     positiveText: positiveText!,),
        bottom!
      ],
    );
  }
}
