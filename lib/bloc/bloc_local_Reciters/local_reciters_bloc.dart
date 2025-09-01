import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilawah_app/bloc/bloc_local_Reciters/local_reciters_event.dart';
import 'package:tilawah_app/bloc/bloc_local_Reciters/local_reciters_state.dart';
import 'package:tilawah_app/model/local_reciter.dart';
import 'package:tilawah_app/repository/local_reciters_repository.dart';


class LocalRecitersBloc extends Bloc<LocalRecitersEvent, LocalRecitersState> {
  final LocalRecitersRepository localRecitersRepository;

  LocalRecitersBloc(this.localRecitersRepository)
      : super(LoadingLocalReciters()) {
    on<LoadLocalRecitersEvent>((event, emit) async {
      emit(LoadingLocalReciters());
      try {
        final List<Reciter> localreciters =
            await localRecitersRepository.getLocalReciters(event.language);
        emit(LoadedLocalReciters(localreciters: localreciters));
      } catch (e) {
        if (e is SocketException) {
          emit(ErrorInLoadLocalReciters(
              errorMsg: 'Check your internet network'));
        } else {
          emit(ErrorInLoadLocalReciters(errorMsg: 'Something Went Wrong'));
        }
      }
    });
  }
}
