import 'package:equatable/equatable.dart';
import 'package:tilawah_app/model/local_reciter.dart';

abstract class LocalRecitersState extends Equatable {}

class LoadingLocalReciters extends LocalRecitersState {
  @override
  List<Object?> get props => [];
}

class LoadedLocalReciters extends LocalRecitersState {
  final List<Reciter> localreciters;

  LoadedLocalReciters({required this.localreciters});
  @override
  List<Object?> get props => [];
}

class ErrorInLoadLocalReciters extends LocalRecitersState {
  final String errorMsg;

  ErrorInLoadLocalReciters({required this.errorMsg});
  @override
  
  List<Object?> get props => [];
}
