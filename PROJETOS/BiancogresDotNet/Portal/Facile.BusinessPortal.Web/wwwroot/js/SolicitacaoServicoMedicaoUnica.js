$(function () {

    $('.div-anexo-nota-fiscal').on('click', '.btn-anexo-medicao-nota-fiscal', function () {
        var Id = $('input[name=SolicitacaoServicoID]').val();
        $('form[name=cadAnexoMedicaoNotaFiscal] input[name=SolicitacaoServicoID]').val(Id);
        $('#modal-anexo-medicao-nota-fiscal').modal('show');
    });


    $('.btn-salvar-aprovar-reprovar-nf').on('click', function () {
        var Id = $('form[name=cadMedicaoAprovarReprovarNF] input[name=SolicitacaoServicoMedicaoUnicaID]').val();
        var Status = $('form[name=cadMedicaoAprovarReprovarNF] input[name=MedicaoEvento]').val()
        var Observacao = $("form[name=cadMedicaoAprovarReprovarNF] textarea[name='Observacao']").val();
        $('#modal-item-medicao-aprovar-reprovada-nf').modal('hide');
        SalvarStatus(Id, Status, Observacao);
    });

    $('.div-anexo-nota-fiscal').on('click', '.btn-atualizar-status-nf', function () {
        var Id = $(this).closest('a').attr('SolicitacaoServicoMedicaoUnicaID');
        var Status = $(this).closest('a').attr('Status');

        $('form[name=cadMedicaoAprovarReprovarNF] input[name=SolicitacaoServicoMedicaoUnicaID]').val(Id);
        $('form[name=cadMedicaoAprovarReprovarNF] input[name=MedicaoEvento]').val(Status)

        $('#modal-item-medicao-aprovar-reprovada-nf').modal('show');
    });


    $('.btn-salvar-anexo-nota-fiscal').on('click', function () {
        SalvarAnexo();
    });

});


function SalvarAnexo() {

    $('#modal-anexo-medicao-nota-fiscal').modal('hide');
    Swal.fire(
        {
            text: "Deseja salvar os arquivo informado?",
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
                    url: '/Compra/SolicitacaoServicoMedicaoUnica/SalvarAnexo',
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


function SalvarStatus(Id, Status, Observacao) {

    var textPergunta = "";
    var textResultado = "";

    if (Status == 'AF') {
        textPergunta = "Deseja aprovar nota fiscal?";
        textResultado = "Nota fiscal aprovada com sucesso.";
        Status = '3';
    } else if (Status == 'RF') {
        textPergunta = "Deseja reprovar nota fiscal?";
        textResultado = "Nota fiscal reprovado com sucesso.";
        Status = '1';
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
                    '/Compra/SolicitacaoServicoMedicaoUnica/SalvarStatus',
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

