import 'package:flutter/material.dart';
import '../theme/app_styles.dart';
import '../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int page = 0;

  List<Map<String, String>> onboardingData = [
    {
      "emoji": "🤝",
      "title": "Welcome to Frendly",
      "desc": "A place to connect with people who matter.",
    },
    {
      "emoji": "🔍",
      "title": "Discover new stories",
      "desc": "Explore posts, reels, and trending topics.",
    },
    {
      "emoji": "💬",
      "title": "Chat instantly",
      "desc": "Stay in touch with friends anytime.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F1FF), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: isTablet ? 20 : 16,
                      ),
                    ),
                  ),
                ),
              ),

              // Main content
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: onboardingData.length,
                  onPageChanged: (i) => setState(() => page = i),
                  itemBuilder: (_, i) {
                    return Column(
                      children: [
                        const Spacer(flex: 1),

                        // Emoji / Image
                        Text(
                          onboardingData[i]["emoji"]!,
                          style: TextStyle(fontSize: isTablet ? 140 : 90),
                        ),

                        SizedBox(height: isTablet ? 40 : 20),

                        // Title
                        Text(
                          onboardingData[i]["title"]!,
                          textAlign: TextAlign.center,
                          style: AppStyles.screenTitle.copyWith(
                            fontSize: isTablet ? 34 : 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: isTablet ? 20 : 12),

                        // Description
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 80 : 32,
                          ),
                          child: Text(
                            onboardingData[i]["desc"]!,
                            textAlign: TextAlign.center,
                            style: AppStyles.subtitle.copyWith(
                              fontSize: isTablet ? 20 : 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),

                        const Spacer(flex: 2),
                      ],
                    );
                  },
                ),
              ),

              // Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingData.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.all(4),
                    width: page == i ? (isTablet ? 40 : 24) : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: page == i
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              SizedBox(height: isTablet ? 40 : 24),

              // Next / Get Started button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 24),
                child: SizedBox(
                  width: double.infinity,
                  height: isTablet ? 70 : 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      if (page == onboardingData.length - 1) {
                        Navigator.pushReplacementNamed(context, '/login');
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.ease,
                        );
                      }
                    },
                    child: Text(
                      page == onboardingData.length - 1
                          ? "Get Started"
                          : "Next",
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: isTablet ? 50 : 30),
            ],
          ),
        ),
      ),
    );
  }
}
