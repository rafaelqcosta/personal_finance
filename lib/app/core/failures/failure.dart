class Failure implements Exception {
  Failure(this.message);
  final String message;
}

class ServerFailure extends Failure {
  ServerFailure() : super('Não foi possível processar seu pedido. Tente novamente mais tarde.');
}

class TimeOutFailure extends Failure {
  TimeOutFailure() : super('Tempo de requisição excedido. Tente novamente mais tarde.');
}

class NoConnectionFailure extends Failure {
  NoConnectionFailure() : super('Você está sem conexão. Verifique a sua internet.');
}

class JsonParsingFailure extends Failure {
  JsonParsingFailure() : super('Erro ao tentar converter os dados json.');
}

class AdapterParsingFailure extends Failure {
  AdapterParsingFailure() : super('Erro ao tentar converter o obejeto em Adapter.');
}

class SubtitleFailure extends Failure {
  SubtitleFailure({String message = 'Não foi possível exibir a legenda'}) : super(message);
}

class ExpiredOrInvalidCredentialsFailure extends Failure {
  ExpiredOrInvalidCredentialsFailure({
    String message = 'Você está sem acesso.\nPor favor refaça o login.',
  }) : super(message);
}

class InvalidOrMissingFieldFailure extends Failure {
  InvalidOrMissingFieldFailure({
    String message =
        'Parece que algo deu errado com sua solicitação. Verifique os dados e tente novamente.',
  }) : super(message);
}

class NotFoundFailure extends Failure {
  NotFoundFailure({String message = 'Não encontrado'}) : super(message);
}

class FormFailure extends Failure {
  FormFailure({String message = 'Campo(s) não preenchido(s).'}) : super(message);
}

class CoursesFilterFailure extends Failure {
  CoursesFilterFailure() : super('Não foi possível filtar os cursos!');
}
