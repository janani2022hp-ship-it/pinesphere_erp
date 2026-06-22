// features/student/presentation/widgets/attendance/leave_request_form.dart

import 'package:flutter/material.dart';
import '../../../../../core/widgets/custom_button.dart';

class LeaveRequestForm extends StatelessWidget {

  const LeaveRequestForm({super.key});

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        TextField(
          decoration: InputDecoration(
            hintText: "Reason",
            filled: true,
            fillColor: Colors.white,

            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(18),

              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 18),

        TextField(
          maxLines: 5,

          decoration: InputDecoration(
            hintText: "Explain your leave",
            filled: true,
            fillColor: Colors.white,

            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(18),

              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 24),

        CustomButton(
          text: "Submit Request",
          onTap: () {},
        )
      ],
    );
  }
}