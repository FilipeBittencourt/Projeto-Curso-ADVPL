$(function () {

    $('.btn-salvar-ss').on('click', function () {

        $('#preloader').removeClass('hide');
        $('#preloader div#status').html('Aguarde...');

        var formdata = new FormData($('#FormCad')[0]);

        $.ajax({
            type: 'POST',
            url: '/Compra/SolicitacaoServicoMedicao/ValidarMedicao',
            data: formdata,
            processData: false,
            contentType: false
        }).done(function (d) {

            if (d.ok) {
                $("form[name=FormCad]").submit();
            } else {
                $('#preloader').addClass('hide');

                Swal.fire({
                    type: "error",
                    title: "",
                    text: d.mensagem,
                });

            }

        });
        
    });


    $("input.calc-valor, input.calc-total, input.calc-quantidade, input.calc-valor-servico, input.calc-saldo-medicao, input.calc-medicao").inputmask('currency', {
        "autoUnmask": true,
        radixPoint: ",",
        groupSeparator: ".",
        allowMinus: false,
        prefix: '',
        //digits: 2,
        digitsOptional: false,
        rightAlign: true,
        //unmaskAsNumber: true,
        removeMaskOnSubmit: true
    });


    $('.date-rangepicker').daterangepicker(
    {
        "timePicker": true,
        "timePicker24Hour": true,
        "timePickerSeconds": false,
        "autoApply": true,
        "singleDatePicker": true,
        "showDropdowns": true,
        "applyButtonClasses": "btn-default shadow-0",
        "cancelClass": "btn-success shadow-0",

        "locale":
        {
            format: 'DD/MM/YYYY hh:mm',
            applyLabel: 'Aplicar',
            cancelLabel: 'Cancelar',
        }
    }, function (start, end, label) {

    });

    $('.tabela-medicao').on('click', '.btn-concluir-medicao', function () {
        var Id = $(this).closest('a').attr('SolicitacaoServicoItemMedicaoID');
        var Status = $(this).closest('a').attr('Status');
        SalvarStatus(Id, Status, "");
    });

    $('.tabela-medicao').on('click', '.btn-excluir-medicao', function () {
        var Id = $(this).closest('a').attr('SolicitacaoServicoItemMedicaoID');
        RemoverMedicao(Id);
    });

    $('.tabela-medicao').on('click', '.btn-atualizar-status', function () {
        var Id = $(this).closest('a').attr('SolicitacaoServicoItemMedicaoID');
        var Status = $(this).closest('a').attr('Status');

        $('form[name=cadItemMedicaoAprovarReprovar] input[name=SolicitacaoServicoItemMedicaoID]').val(Id);
        $('form[name=cadItemMedicaoAprovarReprovar] input[name=MedicaoEvento]').val(Status)

        $('#modal-item-medicao-aprovar-reprovada').modal('show');
    });


    $('.div-anexo-nota-fiscal').on('click', '.btn-atualizar-status-nf', function () {
        var Id = $(this).closest('a').attr('SolicitacaoServicoMedicaoID');
        var Status = $(this).closest('a').attr('Status');

        $('form[name=cadMedicaoAprovarReprovarNF] input[name=SolicitacaoServicoMedicaoID]').val(Id);
        $('form[name=cadMedicaoAprovarReprovarNF] input[name=MedicaoEvento]').val(Status)

        $('#modal-item-medicao-aprovar-reprovada-nf').modal('show');
    });



    $('.div-anexo-nota-fiscal').on('click', '.btn-anexo-medicao-nota-fiscal', function () {
        var Id = $(this).closest('a').attr('SolicitacaoServicoMedicaoID');
        $('form[name=cadAnexoMedicaoNotaFiscal] input[name=SolicitacaoServicoMedicaoID]').val(Id);
        $('#modal-anexo-medicao-nota-fiscal').modal('show');
    });


    $('.btn-salvar-aprovar-reprovar').on('click', function () {
        var Id = $('form[name=cadItemMedicaoAprovarReprovar] input[name=SolicitacaoServicoItemMedicaoID]').val();
        var Status = $('form[name=cadItemMedicaoAprovarReprovar] input[name=MedicaoEvento]').val()
        var Observacao = $("form[name=cadItemMedicaoAprovarReprovar] textarea[name='Observacao']").val();
        $('#modal-item-medicao-aprovar-reprovada').modal('hide');
        SalvarStatus(Id, Status, Observacao);
    });

    $('.btn-salvar-aprovar-reprovar-nf').on('click', function () {
        var Id = $('form[name=cadMedicaoAprovarReprovarNF] input[name=SolicitacaoServicoMedicaoID]').val();
        var Status = $('form[name=cadMedicaoAprovarReprovarNF] input[name=MedicaoEvento]').val()
        var Observacao = $("form[name=cadMedicaoAprovarReprovarNF] textarea[name='Observacao']").val();
        $('#modal-item-medicao-aprovar-reprovada-nf').modal('hide');
        SalvarStatusNotaFiscal(Id, Status, Observacao);
    });



    $('.btn-salvar-anexo-nota-fiscal').on('click', function () {
        SalvarAnexoNotaFiscal();
    });



    $('input.calc-medicao').on('keyup', function (e) {

        var tr = $(this).closest('tr');
        var SaldoMedicao = tr.find('input.calc-saldo-medicao').val();
        var Medicao = tr.find('input.calc-medicao').val();
        var ValorServico = tr.find('input.calc-valor-servico').val();
        var Unidade = tr.find('input.calc-unidade-medicao').val();

        tr.find('input.calc-valor').val('0');

        SaldoMedicao = (SaldoMedicao == "") ? "0" : SaldoMedicao.replace(".", "").replace(",", ".");
        Medicao = (Medicao == "") ? "0" : Medicao.replace(".", "").replace(",", ".");
        ValorServico = (ValorServico == "") ? "0" : ValorServico.replace(".", "").replace(",", ".");

        SaldoMedicao = parseFloat(SaldoMedicao);
        Medicao = parseFloat(Medicao);
        ValorServico = parseFloat(ValorServico);

        var Resultado = 0;

        if (Unidade == "1") {
            Resultado = (Medicao / 100) * SaldoMedicao;

            if (Resultado <= SaldoMedicao) {
            
                tr.find('input.calc-total').val(Resultado.toFixed(2).toString().replace(".", ","));

                tr.find('input.calc-valor').val(Resultado.toFixed(2).toString().replace(".", ","));

            } else {
                alert('Porcentagem medição inválida.');
                tr.find('input.calc-medicao').val('0');
            }
        } else {
            var Resultado = Medicao;

            if (Resultado <= SaldoMedicao) {
                Resultado = Medicao * ValorServico;
                tr.find('input.calc-total').val(Resultado.toFixed(2).toString().replace(".", ","));

                tr.find('input.calc-valor').val(Resultado.toFixed(2).toString().replace(".", ","));
            } else {
                alert('Quantidade medição inválida.');
                tr.find('input.calc-medicao').val('0');
                tr.find('input.calc-valor').val('0');
            }
        }
      
    });


    $('input.calc-valor').on('keyup', function () {
        var tr = $(this).closest('tr');

        var SaldoMedicao = tr.find('input.calc-saldo-medicao').val();
        var ValorServico = tr.find('input.calc-valor-servico').val();
        var Valor = tr.find('input.calc-valor').val();
        
        SaldoMedicao = (SaldoMedicao == "") ? "0" : SaldoMedicao.replace(".", "").replace(",", ".");
        ValorServico = (ValorServico == "") ? "0" : ValorServico.replace(".", "").replace(",", ".");
        Valor = (Valor == "") ? "0" : Valor.replace(".", "").replace(",", ".");

        SaldoMedicao = parseFloat(SaldoMedicao);
        ValorServico = parseFloat(ValorServico);
        Valor = parseFloat(Valor);

        var Medicao = 0;
        Medicao = (Valor / SaldoMedicao);

        if (Medicao <= 1) {
            tr.find('input.calc-medicao').val((Medicao * 100).toFixed(2).toString().replace(".", ","));

            Resultado = (Medicao * SaldoMedicao);
            tr.find('input.calc-total').val(Resultado.toFixed(2).toString().replace(".", ","));

        } else {
            alert('Valor medição inválida.');
            tr.find('input.calc-valor').val('0');
            tr.find('input.calc-medicao').val('0');
            tr.find('input.calc-total').val('0');

        }
    });

});


function SalvarAnexoNotaFiscal() {

    $('#modal-anexo-medicao-nota-fiscal').modal('hide');
    Swal.fire(
        {
            text: "Deseja salvar os arquivos informados?",
            type: "warning",
            showCancelButton: true,
            confirmButtonText: "Sim",
            cancelButtonText: "Não"
        }).then(function (result) {
            if (result.value) {

                $('#preloader').removeClass('hide');
                $('#preloader div#status').html('Aguarde...');

                var formdata = new FormData($('#cadAnexoMedicaoNotaFiscal')[0]);

                $.ajax({
                    type: 'POST',
                    url: '/Compra/SolicitacaoServicoMedicao/SalvarAnexoNotaFiscal',
                    data: formdata,
                    processData: false,
                    contentType: false
                }).done(function (d) {

                    $('#preloader').addClass('hide');

                    var type = ""
                    var text = ""

                    if (d.ok) {
                        type = "success";
                        text = "Arquivos salvo com sucesso.";
                        window.location.reload();
                    } else {
                        type = "error"
                        text = d.mensagem
                    }

                    Swal.fire({
                        type: type,
                        title: "",
                        text: text,
                    });

                });

            }
        });
}


function RemoverMedicao(Id) {

    var textPergunta = "Deseja excluir medição?";
    var textResultado = "Medição excluido sucesso.";

    Swal.fire(
        {
            text: textPergunta,
            type: "warning",
            showCancelButton: true,
            confirmButtonText: "Sim",
            cancelButtonText: "Não"
        }).then(function (result) {
            if (result.value) {

                $('#preloader').removeClass('hide');
                $('#preloader div#status').html('Aguarde...');

                $.post(
                    '/Compra/SolicitacaoServicoMedicao/RemoverMedicao',
                    { Id: Id},
                    function (d) {

                        $('#preloader').addClass('hide');

                        var type = ""
                        var text = ""

                        if (d.ok) {
                            type = "success";
                            text = textResultado;

                            window.location.reload();
                            //table.ajax.reload();

                        } else {
                            type = "error"
                            text = d.mensagem
                        }

                        Swal.fire({
                            type: type,
                            title: "",
                            text: text,
                        });

                    }
                );
            }
        });
}

function SalvarStatus(Id, Status, Observacao) {

    var textPergunta = "";
    var textResultado = "";

    if (Status == 'C') {
        textPergunta = "Deseja concluir medição?";
        textResultado = "Medição concluida com sucesso.";
        Status = '1';
    } else if (Status == 'A') {
        textPergunta = "Deseja aprovar medição?";
        textResultado = "Medição aprovada com sucesso.";
        Status = '2';
    } else if (Status == 'R') {
        textPergunta = "Deseja reprovar medição?";
        textResultado = "Medição reprovado com sucesso.";
        Status = '0';
    } else if (Status == 'AF') {
        textPergunta = "Deseja aprovar nota fiscal?";
        textResultado = "Nota fiscal aprovada com sucesso.";
        Status = '4';
    } else if (Status == 'RF') {
        textPergunta = "Deseja reprovar nota fiscal?";
        textResultado = "Nota fiscal reprovado com sucesso.";
        Status = '2';
    }

    Swal.fire(
        {
            text: textPergunta,
            type: "warning",
            showCancelButton: true,
            confirmButtonText: "Sim",
            cancelButtonText: "Não"
        }).then(function (result) {
            if (result.value) {

                $('#preloader').removeClass('hide');
                $('#preloader div#status').html('Aguarde...');

                $.post(
                    '/Compra/SolicitacaoServicoMedicao/SalvarStatus',
                    { Id: Id, Status: Status, Observacao: Observacao },
                    function (d) {

                        $('#preloader').addClass('hide');

                        var type = ""
                        var text = ""

                        if (d.ok) {
                            type = "success";
                            text = textResultado;

                            window.location.reload();

                        } else {
                            type = "error"
                            text = d.mensagem
                        }

                        Swal.fire({
                            type: type,
                            title: "",
                            text: text,
                        });

                    }
                );
            }
        });
}



function SalvarStatusNotaFiscal(Id, Status, Observacao) {

    var textPergunta = "";
    var textResultado = "";

    if (Status == 'C') {
        textPergunta = "Deseja concluir medição?";
        textResultado = "Medição concluida com sucesso.";
        Status = '1';
    } else if (Status == 'A') {
        textPergunta = "Deseja aprovar medição?";
        textResultado = "Medição aprovada com sucesso.";
        Status = '2';
    } else if (Status == 'R') {
        textPergunta = "Deseja reprovar medição?";
        textResultado = "Medição reprovado com sucesso.";
        Status = '0';
    } else if (Status == 'AF') {
        textPergunta = "Deseja aprovar nota fiscal?";
        textResultado = "Nota fiscal aprovada com sucesso.";
        Status = '1';
    } else if (Status == 'RF') {
        textPergunta = "Deseja reprovar nota fiscal?";
        textResultado = "Nota fiscal reprovado com sucesso.";
        Status = '2';
    }

    Swal.fire(
        {
            text: textPergunta,
            type: "warning",
            showCancelButton: true,
            confirmButtonText: "Sim",
            cancelButtonText: "Não"
        }).then(function (result) {
            if (result.value) {

                $('#preloader').removeClass('hide');
                $('#preloader div#status').html('Aguarde...');

                $.post(
                    '/Compra/SolicitacaoServicoMedicao/SalvarStatusNotaFiscal',
                    { Id: Id, Status: Status, Observacao: Observacao },
                    function (d) {

                        $('#preloader').addClass('hide');

                        var type = ""
                        var text = ""

                        if (d.ok) {
                            type = "success";
                            text = textResultado;

                            window.location.reload();

                        } else {
                            type = "error"
                            text = d.mensagem
                        }

                        Swal.fire({
                            type: type,
                            title: "",
                            text: text,
                        });

                    }
                );
            }
        });
}



