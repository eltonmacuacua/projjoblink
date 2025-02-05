import 'package:flutter/material';
import '../../servises/auth/auth_service.dart';
import '../../utils/database_helper.dart';

class RegisterScreen extends StatefulWidget{
    RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
    final _formKey = GlobalKey<FormState>();
    final _authService = AuthService();
    bool _loading - false;

    final _nameController = TextEditingControl();
    final _emailController = TextEditingControl();
    final _passwordController = TextEditingControl();
    final _phoneController = TextEditingControl();

    Future<void> _register() async(){
        if(_form.currentState!.validate()){
            try{
                setState(() => _isLoading = true);

                final user = Usuario (
                    userid: DateTime.now().millisecondsSinceEpoch.toString(),
                    nome: _nameController.text,
                    email: _emailontroller.text,
                    senha: _senhaController.text,
                    telefone: _telefoneController.text,
                    tipoDeUsuario: 'cidadao',
                    especializacao: '',
                    dataCadastro: DateTime.now().toIso6801String(),
                    localizacao: '',
                );

                final success = await _authService.registerUser(user);

                setState(() => _isLoadung = false)

                if(success){
                    ScaffoldMesege.of(context).shoSnackBar
                }
            }
        }
    }
}