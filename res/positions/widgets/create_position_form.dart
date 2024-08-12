
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/widgets/edit_text.dart';

class CreatePositionForm extends ConsumerWidget {
  final signUpFormKey = GlobalKey<FormState>();
  final TextEditingController nameController;
  final TextEditingController firsPriceController;
  final TextEditingController marginalityController;
  final TextEditingController quantityController;
  final TextEditingController dropdownMenuController;
  final bool? isInfoActive;
  final Widget carouselSlider;
  final Widget discountLisView;
  final Widget bottomButton;

  final String strCategory;

  CreatePositionForm({
    super.key,
    required this.nameController,
    required this.firsPriceController,
    required this.marginalityController,
    required this.quantityController,
    required this.dropdownMenuController,
    required this.carouselSlider,
    required this.discountLisView,
    required this.bottomButton,
    this.isInfoActive,
    required this.strCategory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Form(
      key: signUpFormKey,
      child: Column(
        children: [
          carouselSlider,
          const Divider(),
          discountLisView,
          const Divider(),

          Text(strCategory),
          const Divider(),
          EditText(
            controller: nameController,
            textInputType: TextInputType.text,
            labelText: 'Наименование',
            onChanged: (v){},
          ),
          const Divider(),
          EditText(
            controller: firsPriceController,
            textInputType: TextInputType.datetime,
            labelText: 'Закупочная цена',
            onChanged: (v){},
          ),
          const Divider(),
          EditText(
            controller: marginalityController,
            textInputType: TextInputType.datetime,
            labelText: 'Марженальность',
            onChanged: (v){},
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Expanded(
                child: DropdownMenu<String>(
                  controller: dropdownMenuController,
                  inputDecorationTheme: InputDecorationTheme(
                    isDense: true,
                    contentPadding: const EdgeInsets.all(8.0),
                    constraints: BoxConstraints.tight(const
                    Size.fromHeight(50)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  label: const Text('Ед.Изм.'),
                  dropdownMenuEntries: [
                    'Кг',
                    'Гр',
                    'Литр',
                    'Шт',
                    'Метр',
                    'Б-пучок',
                    'М-пучок',
                    'См',
                  ]
                      .map<DropdownMenuEntry<String>>((String value) {
                    return DropdownMenuEntry<String>(
                        value: value, label: value);
                  }).toList(),
                ),
              ),
              Expanded(
                child: EditText(
                  controller: quantityController,
                  textInputType: TextInputType.datetime,
                  labelText: 'Количество',
                  onChanged: (v){},
                ),
              ),
            ],
          ),
          const Divider(),
          bottomButton,
          const Divider(),
        ],
      ),
    );
  }

  validateForm() {
    // if(nameController.text.length < 3)
    // {
    //
    //   Get.snackbar("Ошибка", "Введите имя");
    // }
    // else if(!emailController.text.contains("@"))
    // {
    //   Get.snackbar("Ошибка", "email");
    // }
    // else if(passwordController.text.isEmpty)
    // {
    //   Get.snackbar("Ошибка", "Введите пароль");
    // } else {
    //
    // }
  }
}

//nameController;
// emailController;
// passwordController
