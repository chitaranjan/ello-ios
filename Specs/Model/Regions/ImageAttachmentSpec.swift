////
///  AttachmentSpec.swift
//

@testable import Ello
import Quick
import Nimble


class AttachmentSpec: QuickSpec {
    override func spec() {

        context("NSCoding") {

            var filePath = ""
            if let url = URL(string: FileManager.ElloDocumentsDir()) {
                filePath = url.appendingPathComponent("ImageAttachmentSpec").absoluteString
            }

            beforeEach {
                let testingKeys = APIKeys(
                    key: "", secret: "", segmentKey: "",
                    domain: "https://ello.co"
                    )
                APIKeys.shared = testingKeys
            }
            afterEach {
                APIKeys.shared = APIKeys.default

                do {
                    try FileManager.default.removeItem(atPath: filePath)
                }
                catch {

                }
            }

            context("encoding") {

                it("encodes successfully") {
                    let imageAttachment: Attachment = stub([:])

                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(imageAttachment, toFile: filePath)

                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes successfully") {
                    let imageAttachment: Attachment = stub([
                        "url" : URL(string: "https://www.example12.com")!,
                        "height" : 456,
                        "width" : 110,
                        "type" : "png",
                        "size" : 78787
                    ])

                    NSKeyedArchiver.archiveRootObject(imageAttachment, toFile: filePath)
                    let unArchivedAttachment = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as! Attachment

                    expect(unArchivedAttachment).toNot(beNil())
                    expect(unArchivedAttachment.version) == 1
                    expect(unArchivedAttachment.url.absoluteString) == "https://www.example12.com"
                    expect(unArchivedAttachment.height) == 456
                    expect(unArchivedAttachment.width) == 110
                    expect(unArchivedAttachment.size) == 78787
                    expect(unArchivedAttachment.type) == "png"
                }
            }

        }
    }
}
