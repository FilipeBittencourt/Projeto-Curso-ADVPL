using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20190905_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AntecipacaoHistorico_Antecipacao_TituloPagarID",
                table: "AntecipacaoHistorico");

            migrationBuilder.DropIndex(
                name: "IX_AntecipacaoHistorico_TituloPagarID",
                table: "AntecipacaoHistorico");

            migrationBuilder.DropColumn(
                name: "TituloPagarID",
                table: "AntecipacaoHistorico");

            migrationBuilder.AlterColumn<long>(
                name: "AntecipacaoID",
                table: "AntecipacaoItem",
                nullable: false,
                oldClrType: typeof(long),
                oldNullable: true);

            migrationBuilder.CreateTable(
                name: "Parametro",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    StatusIntegracao = table.Column<int>(nullable: false),
                    DataHoraIntegracao = table.Column<DateTime>(nullable: true),
                    MensagemRetorno = table.Column<string>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    Chave = table.Column<string>(nullable: false),
                    Tipo = table.Column<string>(nullable: false),
                    Valor = table.Column<string>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Parametro", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Parametro_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Parametro_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AntecipacaoHistorico_AntecipcaoID",
                table: "AntecipacaoHistorico",
                column: "AntecipcaoID");

            migrationBuilder.CreateIndex(
                name: "IX_Parametro_EmpresaID",
                table: "Parametro",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_Parametro_UnidadeID",
                table: "Parametro",
                column: "UnidadeID");

            migrationBuilder.AddForeignKey(
                name: "FK_AntecipacaoHistorico_Antecipacao_AntecipcaoID",
                table: "AntecipacaoHistorico",
                column: "AntecipcaoID",
                principalTable: "Antecipacao",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AntecipacaoHistorico_Antecipacao_AntecipcaoID",
                table: "AntecipacaoHistorico");

            migrationBuilder.DropTable(
                name: "Parametro");

            migrationBuilder.DropIndex(
                name: "IX_AntecipacaoHistorico_AntecipcaoID",
                table: "AntecipacaoHistorico");

            migrationBuilder.AlterColumn<long>(
                name: "AntecipacaoID",
                table: "AntecipacaoItem",
                nullable: true,
                oldClrType: typeof(long));

            migrationBuilder.AddColumn<long>(
                name: "TituloPagarID",
                table: "AntecipacaoHistorico",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_AntecipacaoHistorico_TituloPagarID",
                table: "AntecipacaoHistorico",
                column: "TituloPagarID");

            migrationBuilder.AddForeignKey(
                name: "FK_AntecipacaoHistorico_Antecipacao_TituloPagarID",
                table: "AntecipacaoHistorico",
                column: "TituloPagarID",
                principalTable: "Antecipacao",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
