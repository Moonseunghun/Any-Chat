extension DateTimeExtension on DateTime {
  String to24HourFormat() {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String yyyyMMdd() {
    final year = this.year.toString().padLeft(4, '0');
    final month = this.month.toString().padLeft(2, '0');
    final day = this.day.toString().padLeft(2, '0');

    const days = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = days[this.weekday - 1];
    return '$year. $month. $day $weekday요일';
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

bool compareDates(DateTime? date1, DateTime date2) {
  if (date1 == null) {
    return false;
  }

  if (date1.year == date2.year && date1.month == date2.month && date1.day == date2.day) {
    return true;
  } else {
    return false;
  }
}
