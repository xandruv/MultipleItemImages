pageextension 80004 ItemList extends "Item List"
{
    layout
    {
        addafter(ItemAttributesFactBox)
        {

            part(MultiplePictureItem; MultiplePictureItem)
            {
                ApplicationArea = All;
                Caption = 'Pictures', Comment = 'ESP="Imágenes"';
                SubPageLink = "No." = field("No.");
            }
        }
    }
}
