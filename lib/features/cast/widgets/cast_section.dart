import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../bloc/cast_bloc.dart';
import '../bloc/cast_event.dart';
import '../bloc/cast_state.dart';
import 'cast_card.dart';

/// Section in show details rendering the horizontal list of cast members.
class CastSection extends StatelessWidget {
  final int showId;

  const CastSection({super.key, required this.showId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Cast',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 175,
          child: BlocBuilder<CastBloc, CastState>(
            builder: (context, state) {
              if (state is CastLoading || state is CastInitial) {
                return const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                );
              }

              if (state is CastError) {
                return Center(
                  child: TextButton.icon(
                    onPressed: () => context.read<CastBloc>().add(CastRetryRequested(showId)),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Failed to load cast. Tap to retry.'),
                  ),
                );
              }

              if (state is CastEmpty) {
                return const Center(
                  child: Text(
                    'No cast information available.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                );
              }

              if (state is CastLoaded) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.cast.length,
                  itemBuilder: (context, index) {
                    final member = state.cast[index];
                    return CastCard(castMember: member);
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
