extension DateTimeExtension on DateTime {
  String to24HourFormat() {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String toCustomDateFormat() {
    final now = DateTime.now();
    final difference = now.difference(this).inDays;

    if (difference == 0 && day == now.day) {
      final hour = this.hour.toString().padLeft(2, '0');
      final minute = this.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (difference == 1 || (now.day - day == 1 && difference == 0)) {
      return '어제';
    } else {
      final month = this.month.toString().padLeft(2, '0');
      final day = this.day.toString().padLeft(2, '0');
      return '$month월 $day일';
    }
  }
}
