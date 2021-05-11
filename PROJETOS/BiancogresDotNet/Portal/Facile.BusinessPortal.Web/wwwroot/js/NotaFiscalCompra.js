$(function () {
    
    $('.btn-salvar-importacao').on('click', function () {
        SalvarNotaFiscal()
    });

    $('.btn-salvar-informar-pedido').on('click', function () {
        InformarPedidoSalvar()
    });

    $('.btn-salvar-informar-transporte').on('click', function () {
        InformaDadosTransporteSalvar()
    });

    $('.btn-salvar-local-entrega').on('click', function () {
        InformaDadosLocalEntregaSalvar()
    });

    $('.btn-remover-informar-pedido').on('click', function () {
        RemoverPedido()
    });

    $('.btn-remover-informar-transporte').on('click', function () {
        RemoverTransporte()
    });

    $('.btn-salvar-autorizar-entrega').on('click', function () {
        AutorizarEntregaSalvar();
    });

    $('#dt-registro').on('click', '.btn-autorizar-entrega', function () {
        AutorizarEntrega(this)
    })

    $('#dt-registro').on('click', '.btn-modal-informar-pedido', function () {
        InformarPedido(this)
    });

    $('#dt-registro').on('click', '.btn-modal-informar-transporte', function () {
        InformarTransporte(this)
    })

    $('#dt-registro').on('click', '.btn-modal-informar-local-entrega', function () {
        InformarLocalEntrega(this)
    });

    $('select[name=Motorista]').on('change', function () {
        GetDadosMotorista(this)
    });

    //GetDadosMotorista()
    loadSelect2Transportadora('.select2-transportadora');
});


function VisualizarAgendar() {
    $('.new-page')[0].click();
}


function ImportarXML() {
    $('#modal-importacao-xml').modal('show');
}

function InformarLocalEntrega(el) {
    $('#cadLocalEntrega input[name=NotaFiscalCompraId]').val($(el).attr('registroid'));
    $('#modal-informar-local-entrega').modal('show');
}


function RemoverPedido() {

    $('#modal-informar-pedido').modal('hide');

    Swal.fire(
        {
            text: "Deseja remover o pedido da nota fiscal?",
            type: "warning",
            showCancelButton: true,
            confirmButtonText: "Sim",
            cancelButtonText: "Não"
        }).then(function (result) {

            if (result.value) {

                $('#preloader').removeClass('hide');
                $('#preloader div#status').html('Aguarde...');
                var Id = $('#cadInformarPedido input[name=NotaFiscalCompraId]').val();

                $.post(
                    "../Compra/NotaFiscalCompra/RemoverPedidoNotaFiscal",
                    { Id: Id },
                    function (d) {

                        $('#preloader').addClass('hide');
                       

                        if (d.ok) {
                            type = "success";
                            text = "Pedido removido com sucesso.";
                            table.ajax.reload();
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

function RemoverTransporte() {

    $('#modal-informar-transporte').modal('hide');

    Swal.fire(
        {
            text: "Deseja remover dados do transporte da nota fiscal?",
            type: "warning",
            showCancelButton: true,
            confirmButtonText: "Sim",
            cancelButtonText: "Não"
        }).then(function (result) {

            if (result.value) {

                $('#preloader').removeClass('hide');
                $('#preloader div#status').html('Aguarde...');
                var Id = $('#cadInformarTransporte input[name=NotaFiscalCompraId]').val();

                $.post(
                    "../Compra/NotaFiscalCompra/RemoverDadosTransporteNotaFiscal",
                    { Id: Id },
                    function (d) {

                        $('#preloader').addClass('hide');
                       

                        if (d.ok) {
                            type = "success";
                            text = "Transporte removido com sucesso.";
                            table.ajax.reload();
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

function AutorizarEntrega(el) {
    var TipoFrete = $(el).attr('tipofrete')
    if (TipoFrete != 'CIF') {
        Swal.fire({
            type: 'error',
            title: "",
            text: "Essa operação é apenas permitida para frete tipo: CIF",
        });
        return
    }

    var Id = $(el).attr('registroid');
    $('#cadAutorizarEntrega input[name=NotaFiscalCompraId]').val($(el).attr('registroid'));

    $('#preloader').removeClass('hide');
    $('#preloader div#status').html('Aguarde...');

    $.get(
        "../Compra/NotaFiscalCompra/GetDadosTransporteNotaFiscal",
        { Id: Id},
        function (d) {

            $('#preloader').addClass('hide');
            $('#modal-informar-pedido').modal('hide');

            if (d.items.length > 0) {
                $('#cadAutorizarEntrega select[name=TransportadoraID]').val(d.items[0].TransportadoraID);
                $('#modal-autorizar-entrega').modal('show');
            }

        }
    );

}

function AutorizarEntregaSalvar() {

    var Id = $('#cadAutorizarEntrega input[name=NotaFiscalCompraId]').val();
    var TransportadoraID = $('#cadAutorizarEntrega select[name=TransportadoraID]').val();

    if (TransportadoraID != "" && Id != "") {

        $('#preloader').removeClass('hide');
        $('#preloader div#status').html('Aguarde...');

        $.get(
            "../Compra/NotaFiscalCompra/SalvarAutorizarEntrega",
            { Id: Id, TransportadoraID: TransportadoraID },
            function (d) {

                $('#preloader').addClass('hide');
                $('#modal-informar-pedido').modal('hide');

                if (d.ok) {
                    type = "success";
                    text = "Transporte Autorizado com sucesso.";
                    table.ajax.reload();
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
    } else {
        Swal.fire({
            type: "error",
            title: "",
            text: "Transportadora não informada.",
        });
    }
    
   
}


function InformarPedido(el) {

    var TipoFrete = $(el).attr('tipofrete')
    $('#cadInformarPedido input[name=NotaFiscalCompraId]').val($(el).attr('registroid'));

    if (TipoFrete == 'FOB') {
        Swal.fire({
            type: 'error',
            title: "",
            text: "Essa operação é apenas permitida para frete tipo: CIF",
        });
        return;
    }

    $('#cadInformarPedido input[name=Pedido]').val('');
    $('#cadInformarPedido input[name=PedidoItem]').val('');


    $('#preloader').removeClass('hide');
    $('#preloader div#status').html('Aguarde...');
    var Id = $(el).attr('registroid')

    $.get(
        "../Compra/NotaFiscalCompra/GetDadosPedidoNotaFiscal",
        { Id: Id },
        function (d) {
            $('#preloader').addClass('hide');
            $('#modal-informar-pedido').modal('show');

            if (d.items.length > 0) {
                $('#cadInformarPedido input[name=Pedido]').val(d.items[0].numero);
                $('#cadInformarPedido input[name=PedidoItem]').val(d.items[0].numeroItem);
            }

        }
    );
}

function InformarTransporte(el) {

    $('input[name=NotaFiscalCompraId]').val($(el).attr('registroid'));
    var TipoFrete = $(el).attr('tipofrete')

    if (TipoFrete == 'FOB') {
        Swal.fire({
            type: 'error',
            title: "",
            text: "Essa operação é apenas permitida para frete tipo: CIF",
        });
        return
    }

    $('#cadInformarTransporte select[name=Motorista]').val('');
    $('#cadInformarTransporte input[name=Placa]').val('');
    $('#cadInformarTransporte select[name=TipoVeiculoID]').val('');
    $('#cadInformarTransporte select[name=TipoProdutoID]').val('');

    $('#preloader').removeClass('hide');
    $('#preloader div#status').html('Aguarde...');
    var Id = $(el).attr('registroid')
    $.get(
        "../Compra/NotaFiscalCompra/GetDadosTransporteNotaFiscal",
        { Id: Id },
        function (d) {
            $('#preloader').addClass('hide');
          
            if (d.items.length > 0) {
                $('#cadInformarTransporte select[name=Motorista]').val(d.items[0].motoristaID);
                $('#cadInformarTransporte input[name=Placa]').val(d.items[0].placa);
                $('#cadInformarTransporte select[name=TipoVeiculoID]').val(d.items[0].tipoVeiculoID);
                $('#cadInformarTransporte select[name=TipoProdutoID]').val(d.items[0].tipoProdutoID);
                $('#modal-informar-transporte').modal('show');
            }
        }
    );
}

function InformarPedidoSalvar() {

    var Id = $('#cadInformarPedido input[name=NotaFiscalCompraId]').val();
    var Pedido = $('#cadInformarPedido input[name=Pedido]').val();
    var PedidoItem = $('#cadInformarPedido input[name=PedidoItem]').val();

    if (Pedido != "" && PedidoItem != "") {
        $('#preloader').removeClass('hide');
        $('#preloader div#status').html('Aguarde...');

        $.post(
            "../Compra/NotaFiscalCompra/SalvarPedidoNotaFiscal",
            { Id: Id, Pedido: Pedido, PedidoItem: PedidoItem },
            function (d) {
                $('#preloader').addClass('hide');
                $('#modal-informar-pedido').modal('hide');

                if (d.ok) {
                    type = "success";
                    text = "Pedido/Item relacionado a nota com sucesso.";
                    table.ajax.reload();
                } else {
                    type = "error"
                    text = d.mensagem
                }

                Swal.fire({
                    type: type,
                    title: "",
                    text: text,
                });

            },
            'JSON'
        );
    } else {
        Swal.fire({
            type: "error",
            title: "",
            text: "Informe um pedido/item.",
        });
    }
}

function InformaDadosTransporteSalvar() {

    var Id = $('#cadInformarTransporte input[name=NotaFiscalCompraId]').val();
    var Motorista = $('#cadInformarTransporte select[name=Motorista]').val();
    var Placa = $('#cadInformarTransporte input[name=Placa]').val();
    var TipoVeiculo = $('#cadInformarTransporte select[name=TipoVeiculoID]').val();
    var TipoProduto = $('#cadInformarTransporte select[name=TipoProdutoID]').val();

    if (Motorista != "" && Placa != "" && TipoVeiculo != "" && TipoProduto != "") {
        $('#preloader').removeClass('hide');
        $('#preloader div#status').html('Aguarde...');

        $.post(
            "../Compra/NotaFiscalCompra/SalvarDadosTransporteNotaFiscal",
            { Id: Id, TipoVeiculo: TipoVeiculo, TipoProduto: TipoProduto, MotoristaID: Motorista, Placa: Placa },
            function (d) {
                $('#preloader').addClass('hide');
                $('#modal-informar-transporte').modal('hide');

                if (d.ok) {
                    type = "success";
                    text = "Dados dos transporte relacionado a nota com sucesso.";
                    table.ajax.reload();
                } else {
                    type = "error"
                    text = d.mensagem
                }

                Swal.fire({
                    type: type,
                    title: "",
                    text: text,
                });

            },
            'JSON'
        );
    } else {
        Swal.fire({
            type: "error",
            title: "",
            text: "Informe um Tipo Veiculo/Tipo Veiculo/Motorista/Placa.",
        });
    }
}

function InformaDadosLocalEntregaSalvar() {

    var Id = $('#cadLocalEntrega input[name=NotaFiscalCompraId]').val();
    var LocalEntrega = $('#cadLocalEntrega select[name=LocalEntregaID]').val();

    if (LocalEntrega != "") {
        $('#preloader').removeClass('hide');
        $('#preloader div#status').html('Aguarde...');

        $.post(
            "../Compra/NotaFiscalCompra/SalvarLocalEntregaNotaFiscal",
            { Id: Id, LocalEntrega: LocalEntrega},
            function (d) {

                $('#preloader').addClass('hide');

                $('#modal-informar-local-entrega').modal('hide');

                if (d.ok) {
                    type = "success";
                    text = "Local de entrega informado com sucesso.";
                    table.ajax.reload();
                } else {
                    type = "error"
                    text = d.mensagem
                }

                Swal.fire({
                    type: type,
                    title: "",
                    text: text,
                });

            },
            'JSON'
        );
    } else {
        Swal.fire({
            type: "error",
            title: "",
            text: "Informe um Local de Entrega.",
        });
    }
}

function SalvarNotaFiscal() {

    $('#preloader').removeClass('hide');
    $('#preloader div#status').html('Aguarde...');

    var formdata = new FormData();
    formdata.append('file', $('#cadImportacaoXML #customFile')[0].files[0]);

    $.ajax({
        type: 'POST',
        url: "../Compra/NotaFiscalCompra/SalvarNotaFiscal",
        data: formdata,
        processData: false,
        contentType: false
    }).done(function (d) {

        $('#preloader').addClass('hide');
        $('#modal-importacao-xml').modal('hide');

        if (d.ok) {
            type = "success";
            text = "XML importado com sucesso.";
            table.ajax.reload();
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

function GetDadosMotorista(el) {

    $('#preloader').removeClass('hide');
    $('#preloader div#status').html('Aguarde...');
    var Id = $(el).val();

    $.get(
        "../Compra/Motorista/GetDadosMotorista",
        { Id: Id},
        function (d) {
            $('#preloader').addClass('hide');
            $('#modal-informar-pedido').modal('hide');
            $('#cadInformarTransporte input[name=Placa]').val(d.items[0].placa);
        },
        'JSON'
    );
}


function loadSelect2Transportadora(el) {
    var o = el || ".select2"
    var $p = $(this).parent(); 
    $(o).select2(
        {
            ajax: {
                url: "../AdminEmpresa/Transportadora/GetTransportadora",
                dataType: 'json',
                //delay: 250,
                dropdownParent: $('#modal-autorizar-entrega .modal-content'),
                data: function (params) {
                    return {
                        q: params.term, // search term
                        page: params.page
                    };
                },
                processResults: function (data, params) {
                    params.page = params.page || 1;
                    return {
                        results: data.items,
                        pagination:
                        {
                            more: (params.page * 30) < data.total_count
                        }
                    };
                },
                cache: true
            },
            "language": {
                "searching": function () {
                    return "procurando...";
                },
                "inputTooShort": function (args) {
                    var remainingChars = args.minimum - args.input.length;

                    var message = 'Insira ' + remainingChars + ' ou  mais caracteres';

                    return message;
                },
            },
            placeholder: 'Selecione...',
            escapeMarkup: function (markup) {
                return markup;
            }, // let our custom formatter work
            minimumInputLength: 1,
            templateResult: formatRepo,
            templateSelection: formatRepoSelection
        }).change(function (el) {

            var data = $(el.target).select2('data');
            if (data.length > 0) {
              //  $(el.target).closest('div.modal-body').find('input[name="Placa"]').val(data[0].placa);
            }
        });
}

function formatRepo(repo) {
    if (repo.loading) {
        return repo.text;
    }

    var markup = "<div class='select2-result-repository clearfix d-flex'>" +
        "<div class='select2-result-repository__meta'>" +
        "<div class='select2-result-repository__title fs-lg fw-500'>" + repo.cpfcnpj + "</div>";

    markup += "<div class='select2-result-repository__description fs-xs opacity-80 mb-1'>" + repo.nome + "</div>";

    markup += "<div class='select2-result-repository__statistics d-flex fs-sm'>" +
        "<div class='select2-result-repository__forks mr-2'></div>" +
        "<div class='select2-result-repository__stargazers mr-2'></div>" +
        "<div class='select2-result-repository__watchers mr-2'></div>" +
        "</div>" +
        "</div></div>";

    return markup;
}

function formatRepoSelection(repo) {

    return repo.cpfcnpj || repo.text;
}