import 'package:flutter/material.dart';
import 'package:vecinoapp/models/resena.dart';
import 'star_rating.dart';

class ResenaCard extends StatelessWidget {
  final Resena resena;

  const ResenaCard({super.key, required this.resena});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) {
      return 'hace ${diff.inDays} día(s)';
    } else if (diff.inHours > 0) {
      return 'hace ${diff.inHours} hora(s)';
    } else {
      return 'hace ${diff.inMinutes} minuto(s)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    resena.nombreUsuario[0].toUpperCase(),
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resena.nombreUsuario,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      StarRating(
                        rating: resena.calificacion.toDouble(),
                        size: 14,
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(resena.fecha),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(resena.comentario),
          ],
        ),
      ),
    );
  }
}