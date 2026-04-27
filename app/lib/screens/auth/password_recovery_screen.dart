import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SecurityQuestionService {
  static const String _collectionPath = 'users';

  static const List<String> availableQuestions = [
    'What is your pet\'s name?',
    'What was your first teacher\'s name?',
    'What city were you born in?',
    'What is your favorite movie?',
    'What was your first phone number?',
    'What is your mother\'s maiden name?',
    'What was the name of your first school?',
    'What is your favorite book?',
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final SecurityQuestionService _instance =
      SecurityQuestionService._internal();
  factory SecurityQuestionService() => _instance;
  SecurityQuestionService._internal();

  Future<bool> hasSecurityQuestions() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore
          .collection(_collectionPath)
          .doc(user.uid)
          .collection('system')
          .doc('security_questions')
          .get();
      return doc.exists && doc.data() != null;
    } catch (e) {
      debugPrint('SecurityQuestionService: Error checking questions - $e');
      return false;
    }
  }

  Future<void> setupSecurityQuestions(
    List<int> questionIndices,
    List<String> answers,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    if (questionIndices.length != 3 || answers.length != 3) {
      throw Exception('Must provide exactly 3 questions and answers');
    }

    final hashedAnswers = answers.map((a) => _hashAnswer(a)).toList();

    await _firestore
        .collection(_collectionPath)
        .doc(user.uid)
        .collection('system')
        .doc('security_questions')
        .set({
          'questions': questionIndices,
          'answers': hashedAnswers,
          'createdAt': FieldValue.serverTimestamp(),
          'attempts': 0,
        });
  }

  Future<bool> verifySecurityQuestions(List<String> answers) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore
          .collection(_collectionPath)
          .doc(user.uid)
          .collection('system')
          .doc('security_questions')
          .get();

      if (!doc.exists || doc.data() == null) return false;

      final data = doc.data()!;
      final storedAnswers = List<String>.from(data['answers'] ?? []);
      final hashedInput = answers.map((a) => _hashAnswer(a)).toList();

      bool allCorrect = true;
      for (int i = 0; i < storedAnswers.length && i < hashedInput.length; i++) {
        if (storedAnswers[i] != hashedInput[i]) {
          allCorrect = false;
          break;
        }
      }

      if (!allCorrect) {
        await _firestore
            .collection(_collectionPath)
            .doc(user.uid)
            .collection('system')
            .doc('security_questions')
            .update({'attempts': FieldValue.increment(1)});
      }

      return allCorrect;
    } catch (e) {
      debugPrint('SecurityQuestionService: Error verifying - $e');
      return false;
    }
  }

  Future<void> deleteSecurityQuestions() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection(_collectionPath)
          .doc(user.uid)
          .collection('system')
          .doc('security_questions')
          .delete();
    } catch (e) {
      debugPrint('SecurityQuestionService: Error deleting - $e');
    }
  }

  Future<int> getAttempts() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    try {
      final doc = await _firestore
          .collection(_collectionPath)
          .doc(user.uid)
          .collection('system')
          .doc('security_questions')
          .get();
      return doc.data()?['attempts'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  String _hashAnswer(String answer) {
    final normalized = answer.trim().toLowerCase();
    final bytes = utf8.encode(normalized);
    return base64Encode(bytes);
  }
}

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final List<TextEditingController> _answerControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  int _selectedQuestion1 = 0;
  int _selectedQuestion2 = 1;
  int _selectedQuestion3 = 2;

  bool _isLoading = false;
  bool _emailSent = false;
  bool _codeVerified = false;
  bool _securityQuestionsVerified = false;
  String? _error;
  int _step = 1;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _answerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildHeader(isDark),
                const SizedBox(height: 32),
                if (_error != null) ...[
                  _buildErrorBox(_error!, isDark),
                  const SizedBox(height: 16),
                ],
                _buildCurrentStep(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getStepTitle(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1F36),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getStepSubtitle(),
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _getStepTitle() {
    switch (_step) {
      case 1:
        return 'Reset Password';
      case 2:
        return 'Verify Email';
      case 3:
        return 'Security Questions';
      case 4:
        return 'New Password';
      default:
        return 'Reset Password';
    }
  }

  String _getStepSubtitle() {
    switch (_step) {
      case 1:
        return 'Enter your email to start the recovery process';
      case 2:
        return 'We sent a verification code to your email';
      case 3:
        return 'Answer your security questions to continue';
      case 4:
        return 'Create a new password for your account';
      default:
        return '';
    }
  }

  Widget _buildErrorBox(String error, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(bool isDark) {
    switch (_step) {
      case 1:
        return _buildEmailStep(isDark);
      case 2:
        return _buildCodeStep(isDark);
      case 3:
        return _buildSecurityQuestionsStep(isDark);
      case 4:
        return _buildNewPasswordStep(isDark);
      default:
        return _buildEmailStep(isDark);
    }
  }

  Widget _buildEmailStep(bool isDark) {
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.email_outlined,
          isDark: isDark,
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email is required';
            if (!v.contains('@')) return 'Enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton('Send Code', _sendResetCode, isDark),
      ],
    );
  }

  Widget _buildCodeStep(bool isDark) {
    return Column(
      children: [
        _buildTextField(
          controller: _codeController,
          label: 'Verification Code',
          icon: Icons.lock_outline,
          isDark: isDark,
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Code is required';
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton('Verify Code', _verifyCode, isDark),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _isLoading ? null : _sendResetCode,
          child: const Text('Resend Code'),
        ),
      ],
    );
  }

  Widget _buildSecurityQuestionsStep(bool isDark) {
    return Column(
      children: [
        _buildQuestionDropdown(0, isDark),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _answerControllers[0],
          label: 'Your Answer',
          icon: Icons.question_answer_outlined,
          isDark: isDark,
          validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildQuestionDropdown(1, isDark),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _answerControllers[1],
          label: 'Your Answer',
          icon: Icons.question_answer_outlined,
          isDark: isDark,
          validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildQuestionDropdown(2, isDark),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _answerControllers[2],
          label: 'Your Answer',
          icon: Icons.question_answer_outlined,
          isDark: isDark,
          validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton('Verify Answers', _verifySecurityQuestions, isDark),
      ],
    );
  }

  Widget _buildQuestionDropdown(int index, bool isDark) {
    final selectedIndex = index == 0
        ? _selectedQuestion1
        : (index == 1 ? _selectedQuestion2 : _selectedQuestion3);

    return DropdownButtonFormField<int>(
      value: selectedIndex,
      decoration: InputDecoration(
        labelText: 'Security Question ${index + 1}',
        labelStyle: TextStyle(
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        prefixIcon: Icon(
          Icons.help_outline,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: SecurityQuestionService.availableQuestions.asMap().entries.map((
        entry,
      ) {
        return DropdownMenuItem(
          value: entry.key,
          child: Text(
            entry.value,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          if (index == 0) {
            _selectedQuestion1 = value;
          } else if (index == 1) {
            _selectedQuestion2 = value;
          } else {
            _selectedQuestion3 = value;
          }
        });
      },
    );
  }

  Widget _buildNewPasswordStep(bool isDark) {
    return Column(
      children: [
        _buildTextField(
          controller: _newPasswordController,
          label: 'New Password',
          icon: Icons.lock_outline,
          isDark: isDark,
          isPassword: true,
          validator: (v) {
            if (v == null || v.length < 6)
              return 'Password must be at least 6 characters';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          icon: Icons.lock_outline,
          isDark: isDark,
          isPassword: true,
          validator: (v) {
            if (v != _newPasswordController.text)
              return 'Passwords do not match';
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton('Reset Password', _resetPassword, isDark),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF6366F1),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed, bool isDark) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        _emailSent = true;
        _step = 2;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to send reset email. Please check your email address.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check your email and click the reset link'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _verifySecurityQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check your email and click the reset link'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final email = _emailController.text.trim();
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password reset email sent! Note: If you have E2E encryption enabled, '
              'changing your password may make your cloud data inaccessible. '
              'Please also check your security questions.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 8),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to reset password. Please try again.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
