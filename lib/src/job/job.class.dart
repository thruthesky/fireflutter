import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class Job {
  // Jobs
  static CollectionReference get jobCol =>
      FirebaseFirestore.instance.collection('jobs');
  static CollectionReference get jobSeekerCol =>
      FirebaseFirestore.instance.collection('job-seekers');

  static final String jobOpenings = 'jobOpenings';
  static final String jobSeekers = 'jobSeekers';

  static final apiUrl =
      "https://www.juso.go.kr/addrlink/addrEngApi.do?currentPage=1&countPerPage=100&confmKey=U01TX0FVVEgyMDIyMDQwNzIyMDI0MDExMjQzNzE=&resultType=json&keyword=";

  /// DB 에 저장되는 값이 아래와 같이 동일한 문자로 저장이 된다. 대소문자 및 철자가 동일하다.
  /// 그래서, 검색을 할 때, 동일하게 검색 할 수 있는 것이다.
  static final Map<String, List<String>> areas = {
    'Seoul': [
      'Jongno-gu',
      'Jung-gu',
      'Yongsan-gu',
      'Seongdong-gu',
      'Gwangjin-gu',
      'Dongdaemun-gu',
      'Jungnang-gu',
      'Seongbuk-gu',
      'Gangbuk-gu',
      'Dobong-gu',
      'Nowon-gu',
      'Eunpyeong-gu',
      'Seodaemun-gu',
      'Mapo-gu',
      'Yangcheon-gu',
      'Gangseo-gu',
      'Guro-gu',
      'Gumcheon-gu',
      'Yeongdeungpo-gu',
      'Dongjak-gu',
      'Gwanak-gu',
      'Seocho-gu',
      'Gangnam-gu',
      'Songpa-gu',
      'Gangdong-gu',
    ],
    'Busan': [
      'Jung-gu',
      'Seo-gu',
      'Dong-gu',
      'Yeongdo-gu',
      'Busanjin-gu',
      'Dongnae-gu',
      'Nam-gu',
      'Buk-gu',
      'Haeundae-gu',
      'Saha-gu',
      'Geumjeong-gu',
      'Gangseo-gu',
      'Yeonje-gu',
      'Suyeong-gu',
      'Sasang-gu',
      'Gijang-gun',
    ],
    'Daegu': [
      'Jung-gu',
      'Dong-gu',
      'Seo-gu',
      'Nam-gu',
      'Buk-gu',
      'Suseong-gu',
      'Dalseo-gu',
      'Dalseong-gun',
    ],
    'Incheon': [
      'Jung-gu',
      'Dong-gu',
      'Michuhol-gu',
      'Yeonsu-gu',
      'Namdong-gu',
      'Bupyeong-gu',
      'Gyeyang-gu',
      'Seo-gu',
      'Ganghwa-gun',
      'Ongjin-gun',
    ],
    'Gwangju': [
      'Dong-gu',
      'Seo-gu',
      'Nam-gu',
      'Buk-gu',
      'Gwangsan-gu',
    ],
    'Daejeon': [
      'Dong-gu',
      'Jung-gu',
      'Seo-gu',
      'Yuseong-gu',
      'Daedeok-gu',
    ],
    'Ulsan': [
      'Jung-gu',
      'Nam-gu',
      'Dong-gu',
      'Buk-gu',
      'Ulju-gun',
    ],
    'Sejong': [],
    'Gyeonggi-do': [
      'Suwon-si',
      'Jangan-gu',
      'Gwonseon-gu',
      'Paldal-gu',
      'Yeongtong-gu',
      'Seongnam-si',
      'Sujeong-gu',
      'Jungwon-gu',
      'Bundang-gu',
      'Uijeongbu-si',
      'Anyang-si',
      'Manan-gu',
      'Dongan-gu',
      'Bucheon-si',
      'Gwangmyeong-si',
      'Pyeongtaek-si',
      'Dongducheon-si',
      'Ansan-si',
      'Sangnok-gu',
      'Danwon-gu',
      'Goyang-si',
      'Deogyang-gu',
      'Ilsandong-gu',
      'Ilsanseo-gu',
      'Gwacheon-si',
      'Guri-si',
      'Namyangju-si',
      'Osan-si',
      'Siheung-si',
      'Gunpo-si',
      'Uiwang-si',
      'Hanam -si',
      'Yongin-si',
      'Cheoin-gu',
      'Giheung-gu',
      'Suji-gu',
      'Paju-si',
      'Icheon-si',
      'Anseong-si',
      'Gimpo-si',
      'Hwaseong-si',
      'Gwangju-si',
      'Yangju-si',
      'Pocheon-si',
      'Yeoju-si',
      'Yeoncheon-gun',
      'Gapyeong-gun',
      'Yangpyeong-gun',
    ],
    'Gangwon-do': [
      'Chuncheon-si',
      'Wonju-si',
      'Gangneung-si',
      'Donghae-si',
      'Taebaek-si',
      'Sokcho-si',
      'Samcheok-si',
      'Hongcheon-gun',
      'Hoengseong-gun',
      'Yeongwol-gun',
      'Pyongchang-gun',
      'Jeongseon-gun',
      'Cheorwon-gun',
      'Hwacheon-gun',
      'Yanggu-gun',
      'Inje-gun',
      'Goseong-gun',
      'Yangyang-gun',
    ],
    'Chungcheongbuk-do': [
      'Cheongju-si',
      'Sangdang-gu',
      'Seowon-gu',
      'Heungdeok-gu',
      'Cheongwon-gu',
      'Chungju-si',
      'Jecheon-si',
      'Boeun-gun',
      'Okcheon-gun',
      'Yeongdong-gun',
      'Jeungpyeong -gun',
      'Jincheon-gun',
      'Goesan-gun',
      'Umseong-gun',
      'Danyang-gun',
    ],
    'Chungcheongnam-do': [
      'Cheonan-si',
      'Dongnam-gu',
      'Sebuk-gu',
      'Gongju-si',
      'Boryeong-si',
      'Asan-si',
      'Seosan-si',
      'Nonsan-si',
      'Gyeryong-si',
      'Dangjin-si',
      'Gumsan-gun',
      'Buyeo-gun',
      'Socheon-gun',
      'Cheongyang-gun',
      'Hongseong-gun',
      'Yesan-gun',
      'Taean-gun',
    ],
    'Jeollabuk-do': [
      'Jeonju-si',
      'Wansan-gu',
      'Deokjin-gu',
      'Gunsan-si',
      'Iksan-si',
      'Jeongeup-si',
      'Namwon-si',
      'Gimje-si',
      'Wanju-gun',
      'Jinan-gun',
      'Muju-gun',
      'Jangsu-gun',
      'Imsil-gun',
      'Sunchang-gun',
      'Gochang-gun',
      'Buan-gun',
    ],
    'Jeollanam-do': [
      'Mokpo-si',
      'Yeosu-si',
      'Suncheon-si',
      'Naju-si',
      'Gwangyang-si',
      'Damyang-gun',
      'Gokseong-gun',
      'Gurye-gun',
      'Goheung-gun',
      'Boseong-gun',
      'Hwasun-gun',
      'Jangheung-gun',
      'Gangjin-gun',
      'Haenam-gun',
      'Yeongam-gun',
      'Muan-gun',
      'Hampyeong-gun',
      'Yeonggwang-gun',
      'Jangseong-gun',
      'Wando-gun',
      'Jindo-gun',
      'Sinan-gun',
    ],
    'Gyeongsangbuk-do': [
      'Pohang-si',
      'Nam-gu',
      'Buk-gu',
      'Gyeongju-si',
      'Gimcheon-si',
      'Andong-si',
      'Gumi-si',
      'Yeongju-si',
      'Yeongcheon-si',
      'Sangju-si',
      'Mungyeong-si',
      'Gyeongsan-si',
      'Gunwi-gun',
      'Uiseong-gun',
      'Cheongsong-gun',
      'Yeongyang-gun',
      'Yeongdeok-gun',
      'Cheongdo-gun',
      'Goryeong-gun',
      'Seongju-gun',
      'Chilgok-gun',
      'Yecheon-gun',
      'Bonghwa-gun',
      'Uljin-gun',
      'Ulleung-gun',
    ],
    'Gyeongsangnam-do': [
      'Changwon-si',
      'Uichang-gu',
      'Seongsan-gu',
      'Masanhappo-gu',
      'Masanhoewon-gu',
      'Jinhae-gu',
      'Jinju-si',
      'Tongyeong-si',
      'Sacheon-si',
      'Gimhae-si',
      'Miryang-si',
      'Geoje-si',
      'Yangsan-si',
      'Uiryeong-gun',
      'Haman-gun',
      'Changnyeong-gun',
      'Goseong-gun',
      'Namhae-gun',
      'Hadong-gun',
      'Sancheong-gun',
      'Hamyang-gun',
      'Geochang-gun',
      'Hapcheon-gun',
    ],
    'Jeju-do': [
      'Jeju-si',
      'Seogwipo-si',
    ],
  };

  static final Map<String, String> categories = {
    'any': 'Any kind of industry',
    'accountant': 'Accountant',
    'call-center': 'Call center',
    'construction': 'Construction',
    'cook': 'Cook, Chef, Backer',
    'customer-service': 'Customer service',
    'delivery': 'Delivery, Transportation',
    'education': 'Education, Academic, Teacher',
    'entertainer': 'Entertainer, Musician',
    'factory-work': 'Factory work',
    'farm-work': 'Farm work',
    'it': 'Tech & IT',
    'management': 'Management',
    'marketing': 'Marketing, Advertising',
    'office-work': 'Office work, Clerk, Cashier',
    'sales': 'Sales, Waiter, Agent',
    'travel': 'Tour guide, Travel',
  };

// - Let company choose working hours of : 1hour, 2hour, 3hour, ... 14 hours.
// - Let company choose working days in a week: 1 day, 2days, ... 7 days.
// - Let company choose if they provide accommodations: Yes, No.
// - Let comapny choose the salary: 100K Won, 200K Won, ... 4.5M Won.
  static final salaries = [
    '100K',
    '200K',
    '300K',
    '400K',
    '500K',
    '600K',
    '700K',
    '800K',
    '900K',
    '1M',
    '1.1M',
    '1.2M',
    '1.3M',
    '1.4M',
    '1.5M',
    '1.6M',
    '1.7M',
    '1.8M',
    '1.9M',
    '2M',
    '2.1M',
    '2.2M',
    '2.3M',
    '2.4M',
    '2.5M',
    '2.6M',
    '2.7M',
    '2.8M',
    '2.9M',
    '3M',
    '3.1M',
    '3.2M',
    '3.3M',
    '3.4M',
    '3.5M',
    '3.6M',
    '3.7M',
    '3.8M',
    '3.9M',
    '4M',
    '4.1M',
    '4.2M',
    '4.3M',
    '4.4M',
    '4.5M',
  ];

  /// Display popup and let user choose address
  static Future<AddressModel?> showAddressPopupWindow(context) async {
    return showDialog<AddressModel?>(
      context: context,
      builder: (context) {
        final input = TextEditingController();
        AddressSearchModel? search;
        return StatefulBuilder(
          builder: ((context, setState) {
            Future getAddresses([String keyword = '']) async {
              final url = apiUrl + input.text;
              final dio = Dio();
              final res = await dio.get(url);
              search = AddressSearchModel.fromJson(res.data);

              setState(() => {});
            }

            // Yeoksam Miryang-si
            return AlertDialog(
              title: Text(
                'Search address',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: input,
                      decoration:
                          InputDecoration(label: Text("Input address.")),
                      onChanged: (addr) {
                        bounce('addr', 500, (s) async {
                          getAddresses(addr);
                        });
                      }),
                  SizedBox(height: 8),
                  Text(
                    'i.e) 536-9, Sinsa-dong',
                    style: TextStyle(fontSize: 11),
                  ),
                  Container(
                    height: 150,
                    child: search == null
                        ? _inputAddress()
                        : search!.totalCount == 0
                            ? _noAddressFound()
                            : SingleChildScrollView(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...search!.addresses
                                          .map(
                                            (addr) => GestureDetector(
                                              onTap: () => Navigator.of(context)
                                                  .pop(addr),
                                              behavior: HitTestBehavior.opaque,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${addr.roadAddr}',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                  Text(
                                                    '${addr.korAddr}',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                  Divider(),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      // SizedBox(
                                      //   height: 100,
                                      // )
                                    ]),
                              ),
                  ),
                  if (search != null && search!.totalCount > 100)
                    Column(
                      children: [
                        SizedBox(height: 16),
                        Text(
                          '* Warning - there are too much addresses by the search and cannot dispaly all. Please narrow the search.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  static _inputAddress() {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Text(
        'Input address and choose.',
        style: TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  static _noAddressFound() {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Text(
        'No address found. Try again.',
        style: TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}
