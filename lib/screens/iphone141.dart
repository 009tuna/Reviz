import 'package:flutter/material.dart';
import 'package:reviz_develop/theme/tokens.dart';

class IPhone141 extends StatelessWidget {
  const IPhone141({super.key});

  @override
  Widget build(BuildContext context) {
    void goNext() => Navigator.pushNamed(context, 'i_phone_14_2');

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: goNext,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 844,
                padding: const EdgeInsets.only(
                  top: 388,
                  left: padding38,
                  right: padding38,
                  bottom: 73,
                ),
                decoration: const BoxDecoration(
                  boxShadow: shadowDrop1,
                  border: Border.fromBorderSide(
                      BorderSide(width: 1, color: black500)),
                  gradient: LinearGradient(colors: [Color(0xFFCCFD04)]),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: width221,
                      height: 96,
                      padding: const EdgeInsets.only(left: 91),
                      alignment: AlignmentDirectional.topStart,
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topLeft,
                        child: Text(
                          'REVIZ',
                          style: TextStyle(
                            fontSize: 64,
                            fontFamily: 'Post No Bills Jaffna ExtraBold',
                            height: 1.5,
                            letterSpacing: -11.8,
                            color: gray1200,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 155),
                    const SizedBox(
                      width: 312,
                      child: Column(
                        children: [
                          Text(
                            'İki Teker Dünyasında Bir Standart !',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 29.2,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              height: 1.13,
                              color: darkgreen,
                            ),
                          ),
                          SizedBox(height: 43),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: width183,
                                height: 18.3,
                                child: Image(
                                    image: AssetImage('assets/Subtract@2x.png'),
                                    fit: BoxFit.cover),
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Reviz\nTechnologies',
                                style: TextStyle(
                                  fontSize: 9.9,
                                  fontFamily: 'Roboto Flex',
                                  fontWeight: FontWeight.w700,
                                  height: 1.05,
                                  color: gray1200,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                top: 181,
                child: SizedBox(
                  width: width250,
                  height: 250,
                  child: Image(
                      image: AssetImage('assets/reviz-LOGO-1@2x.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
