page 80005 "MultiplePictureItem"
{
    ApplicationArea = All;
    Caption = 'Multiple Pictures', Comment = 'ESP="Múltiples Imágenes"';
    PageType = CardPart;
    SourceTable = Item;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;

    layout
    {
        area(content)
        {
            field(Picture; gblimagetenantMedia.Content)
            {
                ApplicationArea = All;
                ShowCaption = false;
            }
            field(gblImageCounterText; gblImageCounterText)
            {
                Caption = 'Images No.', Comment = 'ESP="Nº Imágenes"';
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ImportPicture)
            {
                ApplicationArea = All;
                Caption = 'Import', Comment = 'ESP="Importar"';
                Image = Import;
                ToolTip = 'Import a picture file.', Comment = 'ESP="Importar un archivo de imagen"';

                trigger OnAction()
                begin
                    ImportImage();
                end;
            }
            action(ExportFile)
            {
                ApplicationArea = All;
                Caption = 'Export', Comment = 'ESP="Exportar"';
                Image = Export;
                ToolTip = 'Export the picture to a file.', Comment = 'ESP="Exportar la imagen a un archivo"';

                trigger OnAction()
                begin
                    ExportImage();
                end;
            }
            action(DeletePicture)
            {
                ApplicationArea = All;
                Caption = 'Delete', Comment = 'ESP="Eliminar"';
                Image = Delete;
                ToolTip = 'Delete the selected picture.', Comment = 'ESP="Eliminar la imagen seleccionada"';

                trigger OnAction()
                begin
                    DeleteImage();
                end;
            }
            action(DeletePictures)
            {
                ApplicationArea = All;
                Caption = 'Delete All', Comment = 'ESP="Eliminar Todas"';
                Image = Delete;
                ToolTip = 'Delete all the pictures.', Comment = 'ESP="Eliminar todas las imagenes"';

                trigger OnAction()
                begin
                    DeleteImages();
                end;
            }
            action(NextPicture)
            {
                ApplicationArea = All;
                Caption = 'Next', Comment = 'ESP="Siguiente"';
                Image = NextRecord;

                trigger OnAction()
                begin
                    ChangeImage('+');
                end;
            }
            action(PrevPicture)
            {
                ApplicationArea = All;
                Caption = 'Previous', Comment = 'ESP="Anterior"';
                Image = PreviousRecord;

                trigger OnAction()
                begin
                    ChangeImage('-');
                end;
            }
        }
    }
    var
        ImageID: Integer;
        gblimagetenantMedia: Record "Tenant Media";
        gblImageCounterText: text;

    trigger OnOpenPage()
    begin
        ImageID := 1;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        LoadImage();
        PictureCounter();
    end;

    /// <summary>
    /// ImportImage
    /// </summary>
    local procedure ImportImage()
    var
        FromFileName: Text;
        count: Integer;
        InStreamImage: InStream;
        FileName: Text;
    begin
        if UploadIntoStream('Import', '', 'All files (*.*)|*.*', FromFileName, InStreamImage) then begin
            if FromFileName = '' then
                exit;
            Rec.Picture.ImportStream(InStreamImage, FromFileName, 'image/*');
            Rec.Modify(true)
        end;
    end;

    /// <summary>
    /// ExportImage
    /// </summary>
    local procedure ExportImage()
    var
        ToFileName: Text;
        ExportPath: Text;
        index: Integer;
        InStreamImage: InStream;
        FileName: Text;
        tenantMedia: Record "Tenant Media";
    begin
        if Rec.Picture.Count = 0 then
            exit;

        for index := 1 to Rec.Picture.Count do begin
            if tenantMedia.Get(rec.Picture.Item(index)) then begin
                tenantMedia.CalcFields(Content);
                if tenantMedia.Content.HasValue then begin
                    FileName := StrSubstNo('Image_%1.jpg', index);
                    tenantMedia.Content.CreateInStream(InStreamImage);
                    DownloadFromStream(InStreamImage, '', '', '', FileName);
                end;
            end;
        end;
    end;

    /// <summary>
    /// PictureCounter
    /// </summary>
    local procedure PictureCounter()
    begin
        if Rec.Picture.Count > 0 then
            gblImageCounterText := Format(ImageID) + '/' + Format(Rec.Picture.Count)
        else
            gblImageCounterText := '0/0';
    end;

    /// <summary>
    /// ChangeImage
    /// </summary>
    /// <param name="operator"></param>
    local procedure ChangeImage(operator: Text)
    begin
        if Rec.Picture.Count = 0 then
            exit;
        case
            operator of
            '+':
                ImageID += 1;
            '-':
                ImageID -= 1;
        end;
        // Ensure ImageID is within valid range
        if (ImageID > Rec.Picture.Count) or (ImageID < 1) then
            ImageID := 1;
        LoadImage();
    end;

    /// <summary>
    /// LoadImage
    /// </summary>
    local procedure LoadImage()
    var
        mediaID: Guid;
    begin
        if xRec."No." <> Rec."No." then
            ImageID := 1;
        if Rec.Picture.Count = 0 then begin
            Clear(gblimagetenantMedia);
            exit;
        end;
        if gblimagetenantMedia.Get(rec.Picture.Item(ImageID)) then begin
            gblimagetenantMedia.CalcFields(Content);
        end;
    end;

    /// <summary>
    /// DeleteImage
    /// </summary>
    local procedure DeleteImage()
    var
        mediaID: Guid;
        Lbl001: Label 'The image %1 has been deleted.', Comment = 'ESP="Se ha eliminado la imagen %1"';
    begin
        // Point to the image displayed on screen
        mediaID := Rec.Picture.Item(ImageID);

        if Rec.Picture.Remove(mediaID) then begin
            Rec.Modify();
            Message(Lbl001, ImageID);
        end;
    end;

    /// <summary>
    /// DeleteImages
    /// </summary>
    local procedure DeleteImages()
    var
        mediaID: Guid;
        Lbl000: Label 'Do you want to delete all images?', Comment = 'ESP="¿Quiere eliminar todas las imágenes?"';
        Lbl001: Label 'The images have been deleted.', Comment = 'ESP="Se han eliminado las imágenes"';
    begin
        if Confirm(Lbl000) then begin
            Clear(Rec.Picture);
            Rec.Modify();
            Message(Lbl001, ImageID);
        end;
    end;
}