// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:redsphere_cbz/core/constants/general_assets.dart';
// import 'package:redsphere_cbz/core/general_helper.dart';
// import 'package:redsphere_cbz/core/utils/shared_pref_methods.dart';
// import 'package:redsphere_cbz/widgets/loading_widgets/circular_loader.dart';
// import 'package:skeletonizer/skeletonizer.dart';

// import '../../core/utils/pallete.dart';
// import '../../fearures/about_us/screens/about_us_screen.dart';
// import '../../fearures/all_loan_management/screens/client_all_loan.dart';
// import '../../fearures/applied_loans/screens/offline_my_loans.dart';
// import '../../fearures/auth/screens/auth_handler.dart';
// import '../../fearures/auth/service/auth_service.dart';
// import '../../fearures/client_management/screens/agent_clients_screen.dart';
// import '../../fearures/client_management/screens/client_on_boarning_screens/document_upload_screen.dart';
// import '../../fearures/faq_management/screens/faq_screens.dart';
// import '../../fearures/offline_client_management/screens/offline_client_screen.dart';
// import '../../fearures/welcome/screens/initial_role_selection.dart';

// class AgentDrawer extends StatefulWidget {
//   AgentDrawer({
//     super.key,
//   });

//   @override
//   State<AgentDrawer> createState() => _AgentDrawerState();
// }

// class _AgentDrawerState extends State<AgentDrawer> {
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: Colors.white,
//       child: ListView(
//         children: [
//           Container(
//             color: Colors.white,
//             height: MediaQuery.of(context).size.height * 0.32,
//             child: DrawerHeader(
//               decoration: const BoxDecoration(color: Colors.white),
//               child: Column(
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       // Get.to( ProfileDetails());
//                     },
//                     child: Container(
//                       width: MediaQuery.of(context).size.height * 0.18,
//                       height: MediaQuery.of(context).size.height * 0.18,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors
//                                 .grey.shade300, // Light color for top shadow
//                             offset: const Offset(-5, -5),
//                             blurRadius: 15,
//                           ),
//                           BoxShadow(
//                             color: Colors
//                                 .grey.shade500, // Dark color for bottom shadow
//                             offset: const Offset(5, 5),
//                             blurRadius: 15,
//                           ),
//                         ],
//                       ),
//                       child: ClipOval(
//                         child: CachedNetworkImage(
//                           imageUrl:
//                               'https://cdn-icons-png.flaticon.com/128/3177/3177440.png',
//                           width: MediaQuery.of(context).size.height * 0.18,
//                           height: MediaQuery.of(context).size.height * 0.18,
//                           fit: BoxFit.cover,
//                           placeholder: (context, url) => Skeletonizer(
//                             enabled: true,
//                             child: SizedBox(
//                               height: MediaQuery.of(context).size.height * 0.45,
//                               child: Image.asset(Assets.blueProfileImage),
//                             ),
//                           ),
//                           errorWidget: (context, url, error) =>
//                               const Icon(Icons.error),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     margin: const EdgeInsets.only(top: 15),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'Mirriam',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Pallete.primaryColor,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           'miriamdube@email.com',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Pallete.primaryColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//           ListTile(
//             leading: Icon(
//               Icons.shopping_bag_outlined,
//               color: Pallete.primaryColor,
//             ),
//             title: const Text('Available Loans'),
//             trailing: const Icon(Icons.navigate_next),
//             onTap: () {
//               Get.to(ViewAllAvailable());
//             },
//           ),
//           ListTile(
//               leading: Icon(
//                 FontAwesomeIcons.peopleGroup,
//                 color: Pallete.primaryColor,
//               ),
//               title: const Text('My Clients'),
//               trailing: const Icon(Icons.navigate_next),
//               onTap: () {
//                 Get.to(AllMyCustomer());
//               }),
//           ListTile(
//               leading: Icon(
//                 FontAwesomeIcons.question,
//                 color: Pallete.primaryColor,
//               ),
//               title: const Text('About Us'),
//               trailing: const Icon(Icons.navigate_next),
//               onTap: () {
//                 Get.to(AboutUsScreen());
//               }),
//           ListTile(
//               leading: Icon(
//                 FontAwesomeIcons.bookOpen,
//                 color: Pallete.primaryColor,
//               ),
//               title: const Text('FAQ'),
//               trailing: const Icon(Icons.navigate_next),
//               onTap: () {
//                 Get.to(FAQScreen());
//               }),
//           ListTile(
//               leading: Icon(
//                 Icons.credit_card,
//                 color: Pallete.primaryColor,
//               ),
//               title: const Text('Clients Offline Only'),
//               trailing: const Icon(Icons.navigate_next),
//               onTap: () async {
//                 Get.to(ClientOfflineScreen());
//                 // Get.to(LoanCalculator())
//               }),
//           ListTile(
//               leading: Icon(
//                 Icons.credit_card,
//                 color: Pallete.primaryColor,
//               ),
//               title: const Text('Aplied Loans Offline'),
//               trailing: const Icon(Icons.navigate_next),
//               onTap: () async {
//                 Get.to(OfflineMyLoans());
//                 // Get.to(LoanCalculator())
//               }),
//           ListTile(
//               leading: Icon(
//                 Icons.settings,
//                 color: Pallete.primaryColor,
//               ),
//               title: const Text('Settings'),
//               trailing: const Icon(Icons.navigate_next),
//               onTap: () async {
//                 // await AuthServices.signOut(context: context)
//                 //     .then((value) async {
//                 //   await SharedPreferencesHelper.clearCachedUserRole()
//                 //       .then((value) {
//                 //     GeneralHelpers.permanentNavigator(
//                 //         context, const InitialRoleSelectionScreen());
//                 //   });
//                 // });
//               }),
//           ListTile(
//               leading: const Icon(
//                 Icons.logout,
//                 color: Colors.redAccent,
//               ),
//               title: const Text(
//                 'Sign Out',
//                 style: TextStyle(color: Colors.redAccent),
//               ),
//               trailing: const Icon(Icons.navigate_next),
//               onTap: () async {
//                 Get.dialog(
//                   const CustomLoader(message: 'Sign Out....'),
//                   barrierDismissible: false,
//                 );

//                 await AuthServices.signOut(context: context).then((value) {
//                   Get.back();
//                   GeneralHelpers.permanentNavigator(
//                       context, const AuthHandler());
//                 });
//                 await CacheUtils.clearCachedRole();
//                 await CacheUtils.updateOnboardingStatus(false).then((value) {
//                   GeneralHelpers.permanentNavigator(
//                       context, const InitialRoleSelectionScreen());
//                 });
//               }),
//         ],
//       ),
//     );
//   }
// }
