import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// =====================================================
// 1. APP
// =====================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile Card',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xffF4F7FB),
      ),
      home: const ProfilePage(),
    );
  }
}

// =====================================================
// 2. PROFILE PAGE
// =====================================================

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F7FB),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: const Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: ProfileCard(),
        ),
      ),
    );
  }
}

// =====================================================
// 3. PROFILE CARD
// =====================================================

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),

        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          ProfileHeader(),

          Padding(
            padding: EdgeInsets.fromLTRB(22, 0, 22, 24),
            child: Column(
              children: [
                ProfileInfo(),

                SizedBox(height: 22),

                ProfileStats(),

                SizedBox(height: 22),

                ProfileButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// 4. PROFILE HEADER + IMAGE
// =====================================================

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,

      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),

        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff2563EB),
            Color(0xff4F46E5),
          ],
        ),
      ),

      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,

        children: [
// Background decoration
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -45,
            child: ProfileImage(),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// 5. PROFILE IMAGE
// =====================================================

class ProfileImage extends StatelessWidget {
  const ProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(5),

          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),

          child: const CircleAvatar(
            radius: 55,

            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
            ),
          ),
        ),

// Online / verified badge
        Positioned(
          right: 4,
          bottom: 8,

          child: Container(
            height: 27,
            width: 27,

            decoration: BoxDecoration(
              color: const Color(0xff22C55E),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),

            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 15,
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================
// 6. PROFILE INFORMATION
// =====================================================

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 45),

// Name
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Jamil',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xff111827),
              ),
            ),

            SizedBox(width: 6),

            Icon(
              Icons.verified,
              color: Color(0xff2563EB),
              size: 21,
            ),
          ],
        ),

        const SizedBox(height: 5),

        const Text(
          'Senior Flutter Developer',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xff6B7280),
          ),
        ),

        const SizedBox(height: 8),

// Location
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.location_on_outlined,
              size: 17,
              color: Color(0xff9CA3AF),
            ),

            SizedBox(width: 4),

            Text(
              'Dhaka, Bangladesh',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xff9CA3AF),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =====================================================
// 7. PROFILE STATS
// =====================================================

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 8,
      ),

      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),

      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          StatItem(
            number: '120',
            label: 'Projects',
          ),

          StatDivider(),

          StatItem(
            number: '8.5K',
            label: 'Followers',
          ),

          StatDivider(),

          StatItem(
            number: '4.9',
            label: 'Rating',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// 8. STAT ITEM
// =====================================================

class StatItem extends StatelessWidget {
  final String number;
  final String label;

  const StatItem({
    super.key,
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xff111827),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xff9CA3AF),
          ),
        ),
      ],
    );
  }
}

// =====================================================
// 9. STAT DIVIDER
// =====================================================

class StatDivider extends StatelessWidget {
  const StatDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: 1,
      color: const Color(0xffE5E7EB),
    );
  }
}

// =====================================================
// 10. BUTTONS
// =====================================================

class ProfileButtons extends StatelessWidget {
  const ProfileButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
// Follow button
        Expanded(
          child: SizedBox(
            height: 48,

            child: ElevatedButton.icon(
              onPressed: () {},

              icon: const Icon(
                Icons.person_add_alt_1,
                size: 18,
              ),

              label: const Text(
                'Follow',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563EB),
                foregroundColor: Colors.white,

                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

// Message button
        Expanded(
          child: SizedBox(
            height: 48,

            child: OutlinedButton.icon(
              onPressed: () {},

              icon: const Icon(
                Icons.chat_bubble_outline,
                size: 18,
              ),

              label: const Text(
                'Message',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xff2563EB),

                side: const BorderSide(
                  color: Color(0xffDBEAFE),
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}